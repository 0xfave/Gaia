// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.23;

import { Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract RooFiRaffle is Ownable, IERC721Receiver {
    struct Raffle {
        IERC721 nft;
        uint256 tokenId;
        uint256 ticketPrice;
        uint256 maxTickets;
        uint256 ticketsSold;
        bool active;
        address[] participants;
    }

    // Mapping from raffleId to Raffle struct
    mapping(uint256 raffleId => Raffle) public raffles;
    uint256 public nextRaffleId;

    event RaffleCreated(uint256 raffleId, address indexed creator, IERC721 indexed nft, uint256 tokenId);
    event RaffleCancelled(uint256 raffleId);
    event TicketPurchased(uint256 raffleId, address indexed participant, uint256 tickets);

    error Roofi_NotNFTOwner();
    error Roofi_RaffleNotActive();
    error Roofi_MaxTicketExceeded();
    error Roofi_NotEnoughFund();

    modifier onlyRaffleCreator(uint256 raffleId) {
        if (msg.sender != raffles[raffleId].nft.ownerOf(raffleId)) revert Roofi_NotNFTOwner();
        _;
    }

    constructor() Ownable(msg.sender) { }

    function createRaffle(IERC721 _nft, uint256 _tokenId, uint256 _ticketPrice, uint256 _maxTickets) external {
        if (_nft.ownerOf(_tokenId) != msg.sender) revert Roofi_NotNFTOwner();

        // Ensure the token is approved for transfer
        IERC721(_nft).transferFrom(msg.sender, address(this), _tokenId);

        raffles[nextRaffleId] = Raffle({
            nft: _nft,
            tokenId: _tokenId,
            ticketPrice: _ticketPrice,
            maxTickets: _maxTickets,
            ticketsSold: 0,
            active: true,
            participants: new address[](0)
        });

        emit RaffleCreated(nextRaffleId, msg.sender, _nft, _tokenId);

        nextRaffleId++;
    }

    function cancelRaffle(uint256 raffleId) external onlyRaffleCreator(raffleId) {
        Raffle storage raffle = raffles[raffleId];

        if (!raffle.active) revert Roofi_RaffleNotActive();

        // Refund Ether to participants
        for (uint256 i = 0; i < raffle.participants.length; i++) {
            address payable participant = payable(raffle.participants[i]);
            participant.transfer(raffle.ticketPrice);
        }

        // Transfer the NFT back to the creator
        raffle.nft.safeTransferFrom(address(this), msg.sender, raffle.tokenId);

        // Deactivate the raffle
        raffle.active = false;

        emit RaffleCancelled(raffleId);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function purchaseTickets(uint256 raffleId, uint256 tickets) external payable {
        Raffle storage raffle = raffles[raffleId];

        if (!raffle.active) revert Roofi_RaffleNotActive();
        if (raffle.ticketsSold + tickets > raffle.maxTickets) revert Roofi_MaxTicketExceeded();
        if (msg.value != raffle.ticketPrice * tickets) revert Roofi_NotEnoughFund();

        // Record the participants
        for (uint256 i = 0; i < tickets; i++) {
            raffle.participants.push(msg.sender);
        }

        // Update the number of tickets sold
        raffle.ticketsSold += tickets;

        emit TicketPurchased(raffleId, msg.sender, tickets);
    }

    // Function to withdraw Ether from the contract by the owner
    function withdrawEther() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
