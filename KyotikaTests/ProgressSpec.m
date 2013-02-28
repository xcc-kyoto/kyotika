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
    
    context(@"when updating", ^{
        it(@"進捗率 25% で寝露に出会う", ^{
            id ud = [NSUserDefaults mock];
            [[ud should] beMemberOfClass:[NSUserDefaults class]];
            [[NSUserDefaults stubAndReturn:ud] standardUserDefaults];
            [[ud should] receive:@selector(floatForKey:) andReturn:theValue(0.0f) withArguments:@"complete"];
            
            KMProgress *p = [[KMProgress alloc] initWithUserDefaults];
            [[theValue(p.complete) should] equal:theValue(0.0f)];
            [[theValue(p.isWaitingForNero) should] beTrue];
            [[theValue(p.canStandbyNero) should] beFalse];
            [[theValue(p.isTogetherWithNero) should] beFalse];
            [[theValue(p.isJustComplete) should] beFalse];
            [[theValue(p.isCompleted) should] beFalse];
            [[theValue(p.messageIndex) should] equal:theValue(0)];
            
            [p updateAnnotations:100 passed:0];
            [[theValue(p.complete) should] equal:theValue(0.2f)];
            [[theValue(p.isWaitingForNero) should] beTrue];
            [[theValue(p.canStandbyNero) should] beFalse];
            [[theValue(p.isTogetherWithNero) should] beFalse];
            [[theValue(p.isJustComplete) should] beFalse];
            [[theValue(p.isCompleted) should] beFalse];
            [[theValue(p.messageIndex) should] equal:theValue(0)];
            
            [p updateAnnotations:100 passed:4];
            [[theValue(p.complete) should] equal:theValue(0.2f)];
            [p updateAnnotations:100 passed:5];
            [[theValue(p.complete) should] equal:theValue(0.4f)];
            [p updateAnnotations:100 passed:6];
            [[theValue(p.complete) should] equal:theValue(0.4f)];
            [[theValue(p.isWaitingForNero) should] beFalse];
            [[theValue(p.canStandbyNero) should] beFalse];
            [[theValue(p.isTogetherWithNero) should] beFalse];
            [[theValue(p.isJustComplete) should] beFalse];
            [[theValue(p.isCompleted) should] beFalse];
            [[theValue(p.messageIndex) should] equal:theValue(1)];
            
            [p updateAnnotations:100 passed:10];
            [[theValue(p.complete) should] equal:theValue(0.6f)];
            [[theValue(p.isWaitingForNero) should] beFalse];
            [[theValue(p.canStandbyNero) should] beFalse];
            [[theValue(p.isTogetherWithNero) should] beFalse];
            [[theValue(p.isJustComplete) should] beFalse];
            [[theValue(p.isCompleted) should] beFalse];
            [[theValue(p.messageIndex) should] equal:theValue(2)];
            
            [p updateAnnotations:100 passed:15];
            [[theValue(p.complete) should] equal:theValue(0.8f)];
            [[theValue(p.isWaitingForNero) should] beFalse];
            [[theValue(p.canStandbyNero) should] beFalse];
            [[theValue(p.isTogetherWithNero) should] beFalse];
            [[theValue(p.isJustComplete) should] beFalse];
            [[theValue(p.isCompleted) should] beFalse];
            [[theValue(p.messageIndex) should] equal:theValue(3)];

            [p updateAnnotations:100 passed:20];
            [[theValue(p.complete) should] equal:theValue(1.0f)];
            [[theValue(p.isWaitingForNero) should] beFalse];
            [[theValue(p.canStandbyNero) should] beTrue];
            [[theValue(p.isTogetherWithNero) should] beTrue];
            [[theValue(p.isJustComplete) should] beFalse];
            [[theValue(p.isCompleted) should] beFalse];
            [[theValue(p.messageIndex) should] equal:theValue(4)];
            
            [p updateAnnotations:100 passed:21];
            [[theValue(p.complete) should] equal:theValue(1.0f)];
            [p updateAnnotations:100 passed:99];
            [[theValue(p.complete) should] equal:theValue(1.0f)];
            [p updateAnnotations:100 passed:100];
            [[theValue(p.complete) should] equal:theValue(2.0f)];
            [[theValue(p.isWaitingForNero) should] beFalse];
            [[theValue(p.canStandbyNero) should] beFalse];
            [[theValue(p.isTogetherWithNero) should] beTrue];
            [[theValue(p.isJustComplete) should] beTrue];
            [[theValue(p.isCompleted) should] beTrue];
            [[theValue(p.messageIndex) should] equal:theValue(4)];
        });
    });
    
    context(@"when saving", ^{
        it(@"should be equal to UserDefaults", ^{
            id ud = [NSUserDefaults mock];
            [[ud should] beMemberOfClass:[NSUserDefaults class]];
            [[NSUserDefaults stubAndReturn:ud] standardUserDefaults];
            [[ud should] receive:@selector(floatForKey:) andReturn:theValue(100.0f) withArguments:@"complete"];
            
            KMProgress *p = [[KMProgress alloc] initWithUserDefaults];
            [[theValue(p.complete) should] equal:theValue(100.0f)];
            
            [[ud should] receive:@selector(setFloat:forKey:) withArguments:theValue(100.0f),@"complete"];
            [[ud should] receive:@selector(synchronize)];
            [p save];
        });
    });
});

SPEC_END