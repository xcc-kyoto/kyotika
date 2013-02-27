#include "Kiwi.h"

SPEC_BEGIN(SampleSpec)

describe(@"Sample", ^{
    context(@"when given 1", ^{
        it(@"should be equal to 1", ^{
            [[theValue(1) should] equal:theValue(1)];
        });
        pending(@"something unimplemented", ^{
        });
    });
});

SPEC_END