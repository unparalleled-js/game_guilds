%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address

from contracts.guild_contract import Permission
from contracts.lib.role import GuildRoles
from contracts.lib.token_standard import TokenStandard

from tests.protostar.setup.setup import Contracts, deploy_all
from tests.protostar.setup.interfaces import Guild, TestNft, Game, Call, CallArray

@external
func __setup__{
    syscall_ptr: felt*, range_check_ptr
}() {
    alloc_locals;
    let addresses: Contracts = deploy_all();

    %{
        context.account1 = ids.addresses.account1
        context.account2 = ids.addresses.account2
        context.account3 = ids.addresses.account3
        context.guild_address = ids.addresses.guild
        context.test_nft_address = ids.addresses.test_nft
        context.game_address = ids.addresses.game_contract
    %}

    return ();
}


@external
func test_add_members{
    syscall_ptr: felt*, range_check_ptr
}() {
    alloc_locals;
    local account1;
    local account2;
    local account3;
    local guild_address;

    %{
        ids.account1 = context.account1
        ids.account2 = context.account2
        ids.account3 = context.account3
        ids.guild_address = context.guild_address
        stop_prank = start_prank(ids.account1, ids.guild_address)
    %}
    Guild.add_member(guild_address, account2, GuildRoles.ADMIN);
    Guild.add_member(guild_address, account3, GuildRoles.OWNER);
    %{
        stop_prank()
    %}
    return ();
}

@external
func test_permissions{
    syscall_ptr: felt*, range_check_ptr
}() {
    alloc_locals;
    local account1;
    local account2;
    local account3;
    local guild_address;
    local test_nft_address;
    local game_address;

    %{
        ids.account1 = context.account1
        ids.account2 = context.account2
        ids.account3 = context.account3
        ids.guild_address = context.guild_address
        ids.test_nft_address = context.test_nft_address
        ids.game_address = context.game_address
        stop_prank_guild = start_prank(ids.account1, ids.guild_address)
        stop_prank_test_nft = start_prank(ids.account1, ids.test_nft_address)
    %}

    TestNft.mint(test_nft_address, account1, Uint256(1, 0));
    TestNft.approve(test_nft_address, guild_address, Uint256(1, 0));
    Guild.deposit(guild_address, TokenStandard.ERC721, test_nft_address, Uint256(1, 0), Uint256(1, 0));
    local kill_goblin_selector;
    %{
        from starkware.starknet.public.abi import get_selector_from_name
        ids.kill_goblin_selector = get_selector_from_name('kill_goblin')
    %}
    let permission = Permission(game_address, kill_goblin_selector);
    let permissions: Permission* = alloc();
    assert permissions[0] = permission;
    Guild.initialize_permissions(
        guild_address, 
        1, 
        permissions
    );
    let call_array: CallArray* = alloc();
    assert call_array[0] = CallArray(
        game_address,
        'kill_goblin',
        0,
        0
    );
    let calldata: felt* = alloc();
    assert calldata[0] = 0;

    Guild.execute_transactions(
        guild_address,
        1,
        call_array,
        1,
        calldata,
        0
    );

    return();
}