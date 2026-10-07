from pricing import total, total_with_discount


def test_total_sums_prices():
    assert total([100, 250]) == 350


def test_total_with_discount():
    total_with_discount([100, 250], 10)
