//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./Registration.sol";
import "./CourseModule.sol";

/**
 * @title WEB3EDU CONTRACT
 */

contract Web3Edu is Registration {
    /**
     *! CONTRACT EVENTS
     */

    event newMouduleCreated(
        address indexed _instructor,
        uint256 _courseFee,
        uint256 _moduleIndex
    );
    event modulePurchase(address indexed _client, uint256 _amount);
    event moduleCertficateClaimed(address indexed _student);

    /**
     * @notice 💡CONTRACT ARRAYS & MAPPINGS
     */
    mapping(CourseModule => uint256) moduleToFee;
    CourseModule[] public courseModules;

    /**
     * @notice 💡 CONTRACT STATE VARIABLES
     */
    uint256 public numberOfModulesCreated;
    uint256 public numberOfModulesPurchased;
    uint256 public immutable moduleCreationFee = 0.02 ether;

    /**@dev This function allows the user creates a module and list a course for that module. A tokenURI is required
*
* @param _courseName The name of the course intended to be created in the module
* @param _courseSymbol This parameter will be requires for the ERC721 certificate
* @param _courseFee The Fee for the course
* @param _certificateURI A URI link to the certificate image and attributes
* @param _courseDuration The estimated length of the course e.g 48 hours

*/
    function createNewModule(
        string memory _courseName,
        string memory _courseSymbol,
        uint256 _courseFee,
        string memory _certificateURI,
        string memory _courseDuration
    )
        external
        payable
        onlyVerifiedInstructors
        paymentCompliance(moduleCreationFee)
        blankCompliance(_courseName, _courseSymbol, _courseDuration, _courseFee)
    {
        require(
            bytes(_certificateURI).length > 0,
            "CertificationURI can't be blank"
        );
        CourseModule newCourseModule = new CourseModule(_certificateURI);
        courseModules.push(newCourseModule);
        newCourseModule.listCourse(
            _courseName,
            _courseSymbol,
            _courseDuration,
            _courseFee
        );

        newCourseModule.createCertificate();

        moduleToFee[newCourseModule] = _courseFee;
        uint256 moduleNumber = numberOfModulesCreated++;

        emit newMouduleCreated(msg.sender, _courseFee, moduleNumber);
    }

    function issueCertificate(address to, uint256 _moduleIndex)
        external
        onlyVerifiedInstructors
    {
        CourseModule newCourseModule = courseModules[_moduleIndex];
        newCourseModule.issueCertificate(to);
    }

  /*  function claimCertificate(uint256 _moduleIndex) external {
        CourseModule newCourseModule = courseModules[_moduleIndex];
        newCourseModule.claimCertificate();

        emit moduleCertficateClaimed(msg.sender);
    }

    function purchaseModule(uint256 _moduleIndex) external {
        CourseModule newCourseModule = courseModules[_moduleIndex];
        newCourseModule.purchaseModule();
        numberOfModulesPurchased++;

        emit modulePurchase(msg.sender, newCourseModule.courseFee());
    }*/
}
