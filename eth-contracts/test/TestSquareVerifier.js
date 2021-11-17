
const truffleAssert = require('truffle-assertions');
const expect = require('chai').expect;

const contractVerifier = artifacts.require('Verifier');
const correctProofFile = require('../../zokrates/code/square/proof.json');

contract('Verifier', accounts => {
    let contractInstance;

    before(async () => {
        contractInstance = await contractVerifier.new({ from: accounts[0] });
    });

    // Test verification with correct proof
    it('should verify with true with the proper proof values', async () => {

        const { proof, inputs } = correctProofFile;
        const { a, b, c } = proof;

        const verificationResult = await contractInstance.verifyTx(
            a,
            b,
            c,
            inputs,
        );

        expect(verificationResult).to.equal(true);
    });

    // Test verification with incorrect proof
    it('should not proof with improper values', async () => {

        const { proof } = correctProofFile;
        const { a, b, c } = proof;

        const verificationResult = await contractInstance.verifyTx(
            a,
            b,
            c,
            [4, 2], // Incorrect inputs
        );

        expect(verificationResult).to.equal(false);
    });
});
