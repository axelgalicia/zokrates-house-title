var ERC721MintableComplete = artifacts.require('ERC721MintableComplete');
const truffleAssert = require('truffle-assertions');

contract('TestERC721Mintable', accounts => {

    const currentOwnerAccount = accounts[0];
    const name = "AX_ERC721MintableToken";
    const symbol = "AX_721M";
    const baseTokenURI = "https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/";
    const zeroAddress = '0x0000000000000000000000000000000000000000';

    let contractInstance;

    describe('match erc721 spec', async () => {
        const tokensIds = [
            10,
            20,
            30,
            40,
            50,
            60,
            70,
            80,
            90,
            100,
            110
        ];

        before(async () => {
            contractInstance = await ERC721MintableComplete.new(name, symbol, { from: currentOwnerAccount });

            // TODO: mint multiple tokens  
            tokensIds.forEach(async (tokenId, index) => {
                if (index < 9) {
                    const account = accounts[index + 1];
                    // console.log(`Minting tokenId: ${tokenId} to account ${account}`);
                    await contractInstance.mint(account, tokenId, { from: currentOwnerAccount });
                }

            })

            await contractInstance.mint(accounts[10], tokensIds[9], { from: currentOwnerAccount });
            await contractInstance.mint(accounts[10], tokensIds[10], { from: currentOwnerAccount });
        })

        it('should return total supply', async () => {
            const totalSupply = await contractInstance.totalSupply.call({ from: accounts[10] });
            expect(Number(totalSupply)).to.equal(tokensIds.length);
        })

        it('should get token balance', async () => {
            const account2Balance = await contractInstance.balanceOf(accounts[2]);
            expect(Number(account2Balance)).to.equal(1);

            const account8Balance = await contractInstance.balanceOf(accounts[8]);
            expect(Number(account8Balance)).to.equal(1);

            const account10Balance = await contractInstance.balanceOf(accounts[10]);
            expect(Number(account10Balance)).to.equal(2);
        })

        // token uri should be complete i.e: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1
        it('should return token uri', async () => {
            const token1Uri = await contractInstance.tokenURI(tokensIds[1]);
            expect(token1Uri).to.deep.equal(`${baseTokenURI}${tokensIds[1]}`);

            const token6Uri = await contractInstance.tokenURI(tokensIds[6]);
            expect(token6Uri).to.deep.equal(`${baseTokenURI}${tokensIds[6]}`);

            const token9Uri = await contractInstance.tokenURI(tokensIds[9]);
            expect(token9Uri).to.deep.equal(`${baseTokenURI}${tokensIds[9]}`);
        })

        it('should transfer token from one owner to another', async () => {
            //accounts[9] -approved for tokensIds[7] will transfer the token to accounts[8]
            const tokenIdToTransfer = tokensIds[7];
            let tx = await contractInstance.transferFrom(accounts[8], accounts[9], tokenIdToTransfer, { from: accounts[8] });
            truffleAssert.eventEmitted(tx, 'Transfer', (ev) => {
                return expect(ev.from).to.deep.equal(accounts[8])
                    && expect(ev.to).to.equal(accounts[9])
                    && expect(Number(ev.tokenId)).to.equal(tokenIdToTransfer);
            });

            expect(await contractInstance.ownerOf(tokenIdToTransfer)).to.equal(accounts[9]);
            expect(Number(await contractInstance.balanceOf(accounts[9]))).to.equal(2);
            expect(Number(await contractInstance.balanceOf(accounts[8]))).to.equal(0);
            expect(await contractInstance.getApproved(tokenIdToTransfer)).to.equal(zeroAddress);
        })
    });

    describe('have ownership properties', async () => {
        before(async () => {
            this.contractInstance = await ERC721MintableComplete.new(name, symbol, { from: currentOwnerAccount });
            // console.log('Current Owner:', currentOwnerAccount);
        })

        it('should fail when minting when address is not contract owner', async function () {

            await expectToRevert(
                contractInstance.mint(
                    accounts[2],
                    500,
                    {
                        from: [accounts[2]]
                    }),
                'Only contract\'s owner can call this function',
            );


        })

        it('should return contract owner', async () => {
            expect(await contractInstance.getOwner({ from: currentOwnerAccount })).to.equal(currentOwnerAccount);
        })

    });
});

const expectToRevert = (promise, errorMessage) => {
    return truffleAssert.reverts(promise, errorMessage);
};