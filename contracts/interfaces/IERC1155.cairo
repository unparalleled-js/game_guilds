# SPDX-License-Identifier: MIT
# OpenZeppelin Contracts for Cairo v0.2.0 (token/erc721/interfaces/IERC721.cairo)

%lang starknet

from starkware.cairo.common.uint256 import Uint256

from openzeppelin.introspection.erc165.library import ERC165

@contract_interface
namespace IERC1155:
    func balanceOf(owner: felt) -> (balance: Uint256):
    end

    func ownerOf(tokenId: Uint256) -> (owner: felt):
    end

    func safeTransferFrom(
            from_: felt, 
            to: felt, 
            tokenId: Uint256,
            amount: Uint256,
            # data_len: felt,
            # data: felt*
        ):
    end

    func safeBatchTransferFrom(
            from_: felt,
            to: felt,
            ids_len: felt,
            ids: Uint256*,
            amounts_len: felt,
            amounts: Uint256*,
            data_len: felt,
            data: felt*,
        ):
    end

    func approve(approved: felt, tokenId: Uint256, amount: Uint256):
    end

    func setApprovalForAll(operator: felt, approved: felt):
    end

    func getApproved(tokenId: Uint256) -> (approved: felt, amount: felt):
    end

    func isApprovedForAll(owner: felt, operator: felt) -> (isApproved: felt):
    end
end
