// Import the necessary packages and libraries
const { ethers } = require("hardhat");
const { expect } = require("chai");

// Describe the contract and its functions
describe("Web3EduContract", () => {
  let web3Edu,
    web3EduContract,
    firstName,
    lastName,
    emailAddress,
    gender,
    experience,
    registrationFee,
    overrides,
    instructor,
    Owner,
    Addr1,
    Addr2,
    Addr3,
    Admin1,
    Admin2,
    student;

  // Deploy the contract before each test
  beforeEach(async () => {
    [Owner, Addr1, Addr2, Addr3, Admin1, Admin2, instructor, student] =
      await ethers.getSigners();

    const Web3Edu = await ethers.getContractFactory("Web3Edu");
    web3EduContract = await Web3Edu.deploy();

    // This adds an admin
    await web3EduContract.addAdmin([Admin1.address, Admin2.address]);

    //web3Edu = web3EduContract.connect(Owner);
  });

  // Test the contract's initialization
  describe("Deployments", () => {
    it("should deploy with the right address", async () => {
      const ownerAddress = await web3EduContract.Owner();
      expect(ownerAddress).to.equal(Owner.address);
    });
  });

  // Test the contract's functions
  describe("Functions", () => {
    beforeEach(() => {
      firstName = "Nafisah";
      lastName = "Ayanlola";
      gender = "Female";
      emailAddress = "nafkem@gmail.com";
      experience = "3";

      registrationFee = ethers.utils.parseEther("0.01");
      overrides = { value: registrationFee };
    });

    // Test script to registerInstructor() function
    it("should register an instructor", async () => {
      await web3EduContract.connect(Addr1)
        .registerInstructor(
          firstName,
          lastName,
          emailAddress,
          gender,
          experience,
          overrides
        );

      const instructorCount = await web3EduContract.getInstructorCount();
      expect(instructorCount).to.equal(1);
    });
    //This should add
    it("should add an admin", async () => {
      await web3EduContract.addAdmin([Admin1.address, Admin2.address]);
    });

    // Test script to verifyInstructors() function
    it("should verify an instructor", async () => {
      const overrides = { gasLimit: 1000000 };
      await web3EduContract
        .connect(Addr1)
        .registerInstructor(
          firstName,
          lastName,
          emailAddress,
          gender,
          experience,
          overrides
        );
      await web3EduContract
        .connect(Admin1)
        .verifyInstructors([Addr1.address], overrides);
      const verifiedInstructorCount =
        await web3EduContract.getVerifiedInstructorCount();
      expect(verifiedInstructorCount).to.equal(1);

      const isVerified = await web3EduContract.isInstructorAddressVerified(
        Addr1.address
      );
      expect(isVerified).to.equal(true);
    });

    //Test script function fireInstructor
    it("should fire instructors", async function () {
      // Add instructor
      await web3EduContract.connect(instructor).registerInstructor(firstName,
        lastName,
        emailAddress,
        gender,
        experience
      );

      // Fire instructor
      await web3EduContract.connect(Admin1).fireInstructor(instructor.address);
      // Check that instructor was fired correctly
      expect(await web3EduContract.isInstructor(instructor.address)).to.be.false;
      expect(await web3EduContract.getInstructorCount()).to.equal(1);
    
      // Register the student
      await web3EduContract.connect(Addr1).enrollStudent(
        firstName,
        lastName,
        emailAddress,
        gender
      );
      const studentCount = await web3EduContract.studentCount();
      expect(studentCount).to.equal(1);
    });
  });
});
