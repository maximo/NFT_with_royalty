import pytest
from brownie import accounts, Unique

@pytest.fixture
def sc(Unique, accounts):
    return Unique.deploy(
        "ERC721 Token", 
        "WN", 
        {"from": accounts[0]}
    )

def test_create_moment(accounts, sc):
    uri = "https://baseuri.com/"
    id = sc.createMoment(
            accounts[1],
            uri,
            {'from': accounts[0]}
        )
    # result value
    print("unique moment ID: ", id.value)
    # emitted event
    print("id: ", id.events['Created']['id'])
    print("unique moment owner: ", sc.ownerOf(id.value))
    assert sc.ownerOf(id.value) == accounts[1]
    assert sc.deleteMoment(id.value)