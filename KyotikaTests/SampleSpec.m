#include "Kiwi.h"
#import "KMProgress.h"

SPEC_BEGIN(ProgressSpec)

describe(@"Progress", ^{
    context(@"when initialized", ^{
        it(@"should be equal to UserDefaults", ^{
            id ud = [NSUserDefaults mock];
            [[ud should] beMemberOfClass:[NSUserDefaults class]];
            [[NSUserDefaults stubAndReturn:ud] standardUserDefaults];
            [[ud should] receive:@selector(floatForKey:) andReturn:theValue(100.0f) withArguments:@"complete"];
            KMProgress *p = [[KMProgress alloc] initWithUserDefaults];
            [[theValue(p.complete) should] equal:theValue(100.0f)];
        });
    });
});

SPEC_END