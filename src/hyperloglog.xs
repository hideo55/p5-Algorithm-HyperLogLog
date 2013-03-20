#define PERL_NO_GET_CONTEXT
#include <stdint.h>
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include "murmur3.h"

#define MAGIC 1
#define HLL_HASH_SEED 313

typedef struct HyperLogLog {
    uint32_t m;
    uint8_t k;
    uint8_t* registers;
    double alphaMM;
}*HLL;

#define GET_HLLPTR(x) get_hll(aTHX_ x, "$self")

static const double two_32 = 4294967296.0;
static const double neg_two_32 = -4294967296.0;

static HLL get_hll(pTHX_ SV* object, const char* context) {
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
    //if (!my_isa_lookup(aTHX_ stash, "Algorithm::HyperLogLog", class_stash, 22, 0)){
    if(!sv_derived_from(object,"Algorithm::HyperLogLog")) {
        croak("%s is not a Algorithm::HyperLogLog", context);
    }
    address = SvIV(sv);
    if (!address)
    croak("Algorithm::HyperLogLog object %s has a NULL pointer", context);
    return INT2PTR(HLL, address);
}

uint8_t rho(uint32_t x, uint8_t b) {
    uint8_t v = 1;
    while (v <= b && !(x & 0x80000000)) {
        v++;
        x <<= 1;
    }
    return v;
}

MODULE = Algorithm::HyperLogLog PACKAGE = Algorithm::HyperLogLog

PROTOTYPES: DISABLE

SV *
new(const char *class, uint32_t k)
PREINIT:
    HLL hll;
    double alpha  = 0.0;
CODE:
{
    New(__LINE__, hll, 1, struct HyperLogLog);
    if( k < 4 || k > 16 ) {
        croak("Number of ragisters must be in the range [4,16]");
    }
    hll->k = k;
    hll->m = 1 << hll->k;
    hll->registers = (uint8_t*)malloc(hll->m * sizeof(uint8_t));
    memset(hll->registers, 0, hll->m);

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
        alpha = 0.7213/(1.0 + (1.079/(double) hll->m));
        break;
    }
    hll->alphaMM = alpha * hll->m * hll->m;

    RETVAL = sv_newmortal();
    sv_setref_pv(RETVAL, class, (void *) hll);
    (void)SvREFCNT_inc(RETVAL);
}
OUTPUT:
    RETVAL

void
add(HLL self, const char* str)
PREINIT:
    uint32_t hash;
    uint32_t index;
    uint8_t rank;
CODE:
{
    MurmurHash3_x86_32((void *) str, strlen(str), HLL_HASH_SEED, (void *) &hash);
    index = (hash >> (32 - self->k));
    rank = rho( (hash << self->k), 32 - self->k );
    if( rank > self->registers[index] ) {
        self->registers[index] = rank;
    }
}

double
estimate(HLL self)
CODE:
{
    double estimate;
    uint32_t m = self->m;
    uint32_t i = 0;
    double sum = 0.0;
    for (i = 0; i < m; i++) {
        sum += 1.0/pow(2.0, self->registers[i]);
    }
    estimate = self->alphaMM/sum; // E in the original paper
    if( estimate <= 2.5 * m ) {
        uint32_t zeros = 0;
        uint32_t i = 0;
        for (i = 0; i < m; i++) {
            if (self->registers[i] == 0) {
                zeros++;
            }
        }
        if( zeros != 0 ) {
            estimate = m * log((double)m/zeros);
        }
    } else if (estimate > (1.0/30.0) * two_32) {
        estimate = neg_two_32 * log(1.0 - ( estimate/two_32 ) );
    }
    
    RETVAL = estimate;
}
OUTPUT:
    RETVAL

void
DESTROY(HLL self)
CODE:
{
    Safefree(self->registers);
    Safefree (self);
}

