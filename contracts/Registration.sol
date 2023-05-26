// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./Managed.sol";

/**
* @title Registration Contract
* @notice This Contract is to be imported hence why the states are private
*/

contract Registration is Managed {
    /**
     * @notice 💡 CONTRACT EVENTS
     */
    event studentRegistered(address indexed _hash);
    event instructorRegistered(
        address indexed hash,
        uint256 indexed experience
    );
    event instructorVerified(address indexed hash, string _lastName);

    /**
     * @notice 💡CONTRACT CONSTRUCTOR
     */

    constructor() {
        Owner = msg.sender;
    }

    /**
     * @notice 💡 CONTRACT STATES
     */
    address[] public admins;
    address public immutable Owner;
    uint256 public immutable instructorRegistrationFee = 0 ether;
    uint256 public studentCount;
    uint256 public instructorCount;
    uint256 public verifiedInstructorCount;
    /**
     * @notice 💡CONTRACT ARRAYS
     */
    Student[] public students;
    Instructor[] public instructors;
    address[] public verifiedInstructors;

    /**
     * @notice 💡 MAPPINGS
     */
    mapping(address => bool) public isStudent;
    mapping(address => bool) public isInstructor;
    mapping(address => bool) public isInstructorVerified;

    /**
     * @notice 💡 CONTRACT ENUMS
     */
    enum VerificationState {
        PENDING,
        VERIFIED
    }
    /**
     * @notice 💡CONTRACT STRUCTS
     */

    struct Student {
        string firstName;
        string lastName;
        string Gender;
        string emailAddress;
        uint256 id;
        address hash;
    }

    struct Instructor {
        string Firstname;
        string Lastname;
        string Gender;
        string emailAddress;
        uint256 experience;
        address hash;
        VerificationState verificationState;
    }

    /**
     * @notice 🔐 CONTRACT MODIFIERS
     */
    modifier onlyVerifiedInstructors() {
        require(
            isInstructorVerified[msg.sender] = true,
            "Not a verified instructor "
        );
        _;
    }

    /**
     * @notice 🔌 WRITE FUNCTIONS
     */
    function addAdmin(address[] memory _adminAddresses)
        public
        onlyOwner(Owner)
    {
        for (uint256 i; i < _adminAddresses.length; i++) {
            admins.push(_adminAddresses[i]);
        }
    }

    function enrollStudent(
        string memory _firstName,
        string memory _lastName,
        string memory _gender,
        string memory _emailAddress
    ) public {
        require(!isStudent[msg.sender], "already registered as a student");
        Student memory newStudent = Student({
            firstName: _firstName,
            lastName: _lastName,
            Gender: _gender,
            emailAddress: _emailAddress,
            id: studentCount++,
            hash: msg.sender
        });
        students.push(newStudent);
        //studentCount = newStudent.id;

        emit studentRegistered(newStudent.hash);
    }

    function registerInstructor(
        string memory _firstName,
        string memory _lastName,
        string memory _gender,
        string memory _emailAddress,
        uint256 _experience
    )
        public
        payable
        paymentCompliance(instructorRegistrationFee)
        registerInstructorCompliance(
            _firstName,
            _lastName,
            _gender,
            _emailAddress,
            _experience
        )
    {
        require(!isInstructor[msg.sender], "already an instructor");
        Instructor memory newInstructor = Instructor({
            Firstname: _firstName,
            Lastname: _lastName,
            Gender: _gender,
            emailAddress: _emailAddress,
            experience: _experience,
            hash: msg.sender,
            verificationState: VerificationState.PENDING
        });
        instructors.push(newInstructor);
        verifiedInstructorCount++;

        emit instructorRegistered(newInstructor.hash, newInstructor.experience);
    }

    function fireInstructor(address _instructorAddress)
        public
        onlyAdmin(admins)
    {
        for (uint256 i; i < instructors.length; i++) {
            if (instructors[i].hash == _instructorAddress) {
                instructors[i] = instructors[instructors.length - 1];
                instructors.pop();
                break;
            }
        }
    }

    function verifyInstructors(address[] memory _instructorAddress)
        public
        onlyAdmin(admins)
    {
        for (uint256 i; i < _instructorAddress.length; i++) {
            Instructor memory instructor = getInstructor(_instructorAddress[i]);
            instructor.verificationState = VerificationState.VERIFIED;
            verifiedInstructors.push(instructor.hash);

            emit instructorVerified(instructor.hash, instructor.Lastname);
        }
    }

    /**
     * @notice 🔌 READ FUNCTIONS
     */

    function getInstructor(address _instructor)
        internal
        view
        onlyAdmin(admins)
        returns (Instructor memory)
    {
        for (uint256 i; i < instructors.length; i++) {
            if (_instructor == instructors[i].hash) {
                return instructors[i];
            }
        }
        revert("Not an Instructor");
    }

    /**
     * @notice 💰 WITHDRAWAL FUNCTIONS
     */
    function withdraw() public virtual onlyOwner(Owner) {
        (bool success, ) = payable(Owner).call{value: address(this).balance}(
            ""
        );
        require(success, "This Transaction Failed");
    }

    /**
     * @notice THE RECEIVE AND FALLBACK FUNCTIONS
     */
    receive() external payable virtual {}

    fallback() external payable virtual {}
}