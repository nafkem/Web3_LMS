// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "./Managed.sol";
import "./Certification.sol";

/**
* @title A COURSE MORDULE CONTRACT
*/

contract CourseModule is Managed {
    event courseListed(string _courseName, uint256 indexed _courseFee);
    event certificateCreated(address indexed _contractAddress);
    event certificationIssued(address indexed _to);
    event certificateClaimed(address indexed _to);

    /**
     * @notice CONTRACT STATES
     */
    address payable public instructorsAddress;
    Course[] public module;
    Certification[] public certificationArray;
    string public certifcationURI;
    address[] public subscribers;
    uint256 public courseFee;
    uint256 public purchaseCount;

    mapping(address => Course) public addressToCourseListed;

    mapping(address => bool) public isSubscriber;
    mapping(address => bool) public isCertificateClaimed;

    /**
     * @notice CONTRACT CONSTRUCTOR
     */
    constructor(string memory _baseURI) {
        instructorsAddress = payable(msg.sender);
        certifcationURI = _baseURI;
    }

    /**
     * @notice CONTRACT STRUCT
     */
    struct Course {
        string courseName;
        string courseSymbol;
        string courseDuration;
        uint256 Fee;
        address InstructorHash;
    }

    /**
     * @notice CONTRACT MODIFIERS
     */

    modifier subscriberCompliance(address _address) {
        require(
            isSubscriber[_address],
            "Only Subscribers can claim certificate"
        );
        _;
    }

    /**
     * @notice WRITE FUNCTIONS
     */
    function listCourse(
        string memory _courseName,
        string memory _courseDuration,
        string memory _courseSymbol,
        uint256 _courseFee
    )
        public
        onlyOwner(instructorsAddress)
        blankCompliance(_courseName, _courseSymbol, _courseDuration, _courseFee)
    {
        Course memory newCourse = Course({
            courseName: _courseName,
            courseSymbol: _courseSymbol,
            courseDuration: _courseDuration,
            Fee: _courseFee,
            InstructorHash: msg.sender
        });
        courseFee = _courseFee;
        if (module.length > 1) {
            revert("Can't create more than course per contract");
        } else {
            module.push(newCourse);
            addressToCourseListed[msg.sender] = newCourse;
        }

        emit courseListed(newCourse.courseName, newCourse.Fee);
    }

    function purchaseModule() public payable paymentCompliance(courseFee) {
        require(
            isSubscriber[msg.sender] = false,
            "You have already purchased this module"
        );
        (bool success, ) = instructorsAddress.call{value: msg.value}("");
        require(success, "Purchase Failed");
        subscribers.push(msg.sender);
        isSubscriber[msg.sender] = true;
        purchaseCount++;
    }

    /**
     * @notice CERTIFICATION FUNCTIONS
     */
    function createCertificate() external onlyOwner(instructorsAddress) {
        if (certificationArray.length > 1) {
            revert("can't create more than 1 certificate per module");
        } else {
            Certification certificate = new Certification(
                module[0].courseName,
                module[0].courseSymbol,
                certifcationURI
            );
            certificationArray.push(certificate);
            Certification certificateAddress = certificationArray[0];
            emit certificateCreated(address(certificateAddress));
        }
    }

    function issueCertificate(address _to)
        external
        onlyOwner(instructorsAddress)
        subscriberCompliance(_to)
    {
        Certification certificate = certificationArray[0];
        certificate.issueDegrees(_to);
        emit certificationIssued(_to);
    }

    function claimCertificate() external subscriberCompliance(msg.sender) {
        Certification certificate = certificationArray[0];
        certificate.claimDegree();
        isCertificateClaimed[msg.sender] = true;
        emit certificateClaimed(msg.sender);
    }

    /**
     * @notice WITHDRAW FUNCTIONS
     */

    function withdraw() public onlyOwner(instructorsAddress) {
        (bool success, ) = instructorsAddress.call{
            value: address(this).balance
        }("");
        require(success, "Withdrawal Failed");
    }
}
