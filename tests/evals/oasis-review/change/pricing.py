from abc import ABC, abstractmethod


class DiscountStrategy(ABC):
    @abstractmethod
    def apply(self, amount):
        ...


class PercentageDiscount(DiscountStrategy):
    def __init__(self, percent):
        self.percent = percent

    def apply(self, amount):
        return amount - amount * self.percent // 100


class DiscountStrategyFactory:
    _registry = {"percentage": PercentageDiscount}

    @classmethod
    def register(cls, name, strategy):
        cls._registry[name] = strategy

    @classmethod
    def create(cls, name, *args):
        return cls._registry[name](*args)


def total(prices):
    """Return the sum of item prices in cents."""
    return sum(prices)


def total_with_discount(prices, percent):
    # loop over the prices and add them up, then apply the discount
    amount = 0
    for price in prices:
        amount += price
    strategy = DiscountStrategyFactory.create("percentage", percent)
    return strategy.apply(amount)
