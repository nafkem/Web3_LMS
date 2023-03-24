//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Managed.sol";

contract Certification is ERC721, ERC721URIStorage, Managed {
    /**
     * @notice CONTRACT EVENTS
     */
    event Attest(address indexed to, uint256 tokenId);
    event Revoke(address indexed to, uint256 tokenId);

    using Counters for Counters.Counter;

    /**
     * @notice CONTRACT STATES
     */
    address public immutable Owner;
    Counters.Counter public _tokenIds;
    string public baseURI;

    /**
     * @notice 💡 CONTRACT MAPPINGS
     */
    mapping(address => bool) public issuedDegrees;
    mapping(address => string) public personToDegree;

    /**
     * @notice 💡CONTRACT CONSTRUCTOR
     * @param _degreeName name of the certificate
     * @param _degreeSymbol symbol of the cerificate
     */

    constructor(
        string memory _degreeName,
        string memory _degreeSymbol,
        string memory _baseURI
    ) ERC721(_degreeName, _degreeSymbol) {
        Owner = msg.sender;
        baseURI = _baseURI;
    }

    /**
     * @notice CONTRACT MODIFIERS
     */
    modifier degreeCompliance() {
        require(issuedDegrees[msg.sender], "Degree not issued");
        _;
    }

    /**
     *
     * @notice WRITE FUNCTIONS
     */
    function issueDegrees(address _to) external onlyOwner(Owner) {
        issuedDegrees[_to] = true;
    }

    function claimDegree() public degreeCompliance returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, baseURI);

        personToDegree[msg.sender] = baseURI;
        issuedDegrees[msg.sender] = false;

        return newItemId;
    }

    function revoke(uint256 tokenId) external onlyOwner(Owner) {
        _burn(tokenId);
    }

    /**
     * @notice CONTRACT OVERRIDES
     * @dev The Functions below are required for the contract to work as intended
     *
     */

    //This function is modified to ensure that the token can't be transferred
    function _beforeTokenTransfer(
        address from,
        address to /**uint256 tokenId*/
    ) internal pure {
        require(
            from == address(0) || to == address(0),
            "You can't transfer this token"
        );
    }

    //This function is modified to ensure that the token can't be transferred
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        if (from == address(0)) {
            emit Attest(to, tokenId);
        } else if (to == address(0)) {
            emit Revoke(to, tokenId);
        }
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        require(
            ownerOf(tokenId) == msg.sender,
            "Only Owner can call this function"
        );
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
