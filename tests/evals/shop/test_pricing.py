from pricing import total


def test_total_sums_prices():
    assert total([100, 250]) == 350
