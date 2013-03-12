#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include "murmur3.h"

#define MAGIC 1
#define is_string(x) (SvOK(x) && !SvROK(x) && (SvPOKp(x) ? SvCUR(x) > 0 : TRUE))

typedef struct HyperLogLog {
    uint32_t m;
    uint32_t k;
    char* registers;
    double alphaMM;
}*HLL;

/* from perl source */
static bool my_isa_lookup(pTHX_ HV *stash, const char *name, HV* name_stash,
        int len, int level) {
    AV* av;
    GV* gv;
    GV** gvp;
    HV* hv = Nullhv;
    SV* subgen = Nullsv;

    /* A stash/class can go by many names (ie. User == main::User), so
     *        we compare the stash itself just in case */
    if ((name_stash && stash == name_stash) ||
            strEQ(HvNAME(stash), name) ||
            strEQ(name, "UNIVERSAL")) return TRUE;

    if (level > 100) croak("Recursive inheritance detected in package '%s'",
            HvNAME(stash));

    gvp = (GV**)hv_fetch(stash, "::ISA::CACHE::", 14, FALSE);

    if (gvp && (gv = *gvp) != (GV*)&PL_sv_undef && (subgen = GvSV(gv)) &&
            (hv = GvHV(gv))) {
        if (SvIV(subgen) == (IV)PL_sub_generation) {
            SV* sv;
            SV** svp = (SV**)hv_fetch(hv, name, len, FALSE);
            if (svp && (sv = *svp) != (SV*)&PL_sv_undef) {
                DEBUG_o( Perl_deb(aTHX_ "Using cached ISA %s for package %s\n",
                                name, HvNAME(stash)) );
                return sv == &PL_sv_yes;
            }
        } else {
            DEBUG_o( Perl_deb(aTHX_ "ISA Cache in package %s is stale\n",
                            HvNAME(stash)) );
            hv_clear(hv);
            sv_setiv(subgen, PL_sub_generation);
        }
    }

    gvp = (GV**)hv_fetch(stash,"ISA",3,FALSE);

    if (gvp && (gv = *gvp) != (GV*)&PL_sv_undef && (av = GvAV(gv))) {
        if (!hv || !subgen) {
            gvp = (GV**)hv_fetch(stash, "::ISA::CACHE::", 14, TRUE);

            gv = *gvp;

            if (SvTYPE(gv) != SVt_PVGV)
            gv_init(gv, stash, "::ISA::CACHE::", 14, TRUE);

            if (!hv)
            hv = GvHVn(gv);
            if (!subgen) {
                subgen = newSViv(PL_sub_generation);
                GvSV(gv) = subgen;
            }
        }
        if (hv) {
            SV** svp = AvARRAY(av);
            /* NOTE: No support for tied ISA */
            I32 items = AvFILLp(av) + 1;
            while (items--) {
                SV* sv = *svp++;
                HV* basestash = gv_stashsv(sv, FALSE);
                if (!basestash) {
                    if (ckWARN(WARN_MISC))
                    Perl_warner(aTHX_ packWARN(WARN_SYNTAX),
                            "Can't locate package %"SVf" for @%s::ISA",
                            sv, HvNAME(stash));
                    continue;
                }
                if (my_isa_lookup(aTHX_ basestash, name, name_stash,
                                len, level + 1)) {
                    (void)hv_store(hv,name,len,&PL_sv_yes,0);
                    return TRUE;
                }
            }
            (void)hv_store(hv,name,len,&PL_sv_no,0);
        }
    }
    return FALSE;
}

static HLL getHLL(pTHX_ SV* object, const char* context) {
    SV *sv;
    HV *stash, *class_stash;
    IV address;

    if (MAGIC) SvGETMAGIC(object);
    if (!SvROK(object)) {
        if (SvOK(object)) croak("%s is not a reference", context);
        croak("%s is undefined", context);
    }
    sv = SvRV(object);
    if (!SvOBJECT(sv)) croak("%s is not an object reference", context);
    stash = SvSTASH(sv);
    /* Is the next even possible ? */
    if (!stash) croak("%s is not a typed reference", context);
    class_stash = gv_stashpv("Algorithm::HyperLogLog", FALSE);
    if (!my_isa_lookup(aTHX_ stash, "Algorithm::HyperLogLog", class_stash, 22, 0))
    croak("%s is not a Algorithm::HyperLogLog", context);
    address = SvIV(sv);
    if (!address)
    croak("Algorithm::HyperLogLog object %s has a NULL pointer", context);
    return INT2PTR(HLL, address);
}

uint32_t popcount32(pTHX_ uint32_t x) {
    x -= (x >> 1) & 0x55555555;
    x = ((x >> 2) & 0x33333333) + (x & 0x33333333);
    x = ((x >> 4) + x) & 0x0F0F0F0F;
    x += (x >> 8);
    x += (x >> 16);
    return(x & 0x0000003F);
}

uint8_t rho(pTHX_ uint32_t x){
    for(uint8_t i=1; i<=32; i++){
      if(x & 1) return i;
      x >>= 1;
    }
    return 33;
}

MODULE = Algorithm::HyperLogLog PACKAGE = Algorithm::HyperLogLog

PROTOTYPES: DISABLE

SV *
new(const char *class, SV* size)
    PREINIT:
        HLL hll;
    CODE:
        New(__LINE__, hll, 1, struct HyperLogLog);
        uint32_t k = SvIV(size);
        if( k < 4 || k > 16 ) {
            croak("Number of ragisters must be in the range [4,16]");
        }
        hll->k = k;
        hll->m = 1 << hll->k;
        hll->registers = (char *)malloc(hll->m * sizeof(char));
        memset(hll->registers, 0, hll->m);

        double alpha = 0.0;
        switch (hll->m) {
            case 16:
                alpha = 0.673;
                break;
            case 32:
                alpha = 0.697;
                break;
            case 64:
                alpha = 0.709;
                break;
            default:
                alpha = 0.7213/(1.0 + 1.079/(double) hll->m);
                break;
        }
        hll->alphaMM = alpha * hll->m * hll->m;

        RETVAL = sv_newmortal();
        sv_setref_pv(RETVAL, class, (void *) hll);
        (void)SvREFCNT_inc(RETVAL);

    OUTPUT:
        RETVAL

void
add(self,arg)
    SV* self
    SV* arg
    CODE:
        HLL p = getHLL(aTHX_ self, "$self");
        STRLEN len;
        const char* str = SvPV_const(arg, len);
        uint32_t hash;
        MurmurHash3_x86_32((void *) str, len, 23, (void *) &hash);
        uint32_t index = (hash >> ( 32 - p->k ));
        uint32_t w = ( hash >> p->k );
        uint8_t rank = rho(aTHX_ w);
        if( rank > p->registers[index] ) {
            p->registers[index] = rank;
        }

SV *
cardinality(self)
        SV* self
    CODE: 
    HLL p = getHLL(aTHX_ self, "$self");
    uint32_t m = p->m;
    static const double two_32 = 4294967296.0;
    static const double neg_two_32 = -4294967296.0;

    uint32_t i;
    uint32_t rank;
    double sum = 0.0;
    for (i = 0; i < m; i++) {
        rank = p->registers[i];
        sum = sum + 1.0/pow(2.0, rank);
    }

    double estimate = p->alphaMM * (1.0 / sum);
    if( estimate <= 2.5 * m ) {
        uint32_t V = 0;
        uint32_t i;

        for (i = 0; i < m; i++) {
            if (p->registers[i] == 0) {
                V++;
            }
        }

        if (V != 0) {
            /* LinearCounting(m,V) */
            estimate = m * log((double)m/V);
        }
    } else if (estimate <= (1.0/30.0) * two_32) {
        estimate = estimate;
    }
    else {
        estimate = neg_two_32 * log(1.0 - estimate/two_32);
    }

    RETVAL = sv_newmortal();
    sv_setnv(RETVAL, estimate);
    (void)SvREFCNT_inc(RETVAL);

    OUTPUT:
        RETVAL

void
hll_DESTROY(self)
        SV* self
    CODE: 
        HLL p = getHLL(aTHX_ self, "$self");
        Safefree(p->registers);
        Safefree (p);

