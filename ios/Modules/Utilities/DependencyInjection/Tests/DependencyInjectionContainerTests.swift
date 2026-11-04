import DependencyInjection
import Testing

struct DependencyInjectionContainerTests {
    private final class Counter {
        var value = 0
    }

    @Test func lazyBuildsOnceOnFirstUse() {
        let container = DependencyInjectionContainer()
        var builds = 0
        container.register(.lazy {
            builds += 1
            return Counter()
        }, for: Counter.self)
        #expect(builds == 0)

        let first = container.resolve(Counter.self)
        let second = container.resolve(Counter.self)
        #expect(first === second)
        #expect(builds == 1)
    }

    @Test func volatileBuildsEveryTime() {
        let container = DependencyInjectionContainer()
        container.register(.volatile { Counter() }, for: Counter.self)
        #expect(container.resolve(Counter.self) !== container.resolve(Counter.self))
    }

    @Test func eagerKeepsTheGivenValue() {
        let container = DependencyInjectionContainer()
        let counter = Counter()
        container.register(.eager(counter), for: Counter.self)
        #expect(container.resolve(Counter.self) === counter)
    }

    @Test func laterRegistrationReplacesEarlier() {
        let container = DependencyInjectionContainer()
        container.register(.eager("first"), for: String.self)
        container.register(.eager("second"), for: String.self)
        #expect(container.resolve(String.self) == "second")
    }

    @Test func dependencyResolvesFromTheInstalledContainer() {
        let container = DependencyInjectionContainer()
        container.register(.eager(42), for: Int.self)
        DependencyInjectionContainer.$shared.withValue(container) {
            @Dependency var answer: Int
            #expect(answer == 42)
        }
    }
}
