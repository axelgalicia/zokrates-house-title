var ERC721MintableComplete = artifacts.require('ERC721MintableComplete');
const truffleAssert = require('truffle-assertions');

contract('TestERC721Mintable', accounts => {

    const account_one = accounts[0];
    const account_two = accounts[1];
    const name = "AX_ERC721MintableToken";
    const symbol = "AX_721M";
    const baseTokenURI = "https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/";
    const zeroAddress = '0x0000000000000000000000000000000000000000';
    let currentOwner;
    let contractInstance;

    describe('match erc721 spec', () => {
        const tokensIds = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110];
        before(async () => {
            contractInstance = await ERC721MintableComplete.new(name, symbol, { from: account_one });
            currentOwner = account_one;

            // TODO: mint multiple tokens  
            await contractInstance.mint(accounts[1], tokensIds[0], { from: account_one });
            await contractInstance.mint(accounts[2], tokensIds[1], { from: account_one });
            await contractInstance.mint(accounts[3], tokensIds[2], { from: account_one });
            await contractInstance.mint(accounts[4], tokensIds[3], { from: account_one });
            await contractInstance.mint(accounts[5], tokensIds[4], { from: account_one });
            await contractInstance.mint(accounts[6], tokensIds[5], { from: account_one });
            await contractInstance.mint(accounts[7], tokensIds[6], { from: account_one });
            await contractInstance.mint(accounts[8], tokensIds[7], { from: account_one });
            await contractInstance.mint(accounts[9], tokensIds[8], { from: account_one });

            await contractInstance.mint(accounts[10], tokensIds[9], { from: account_one });
            await contractInstance.mint(accounts[10], tokensIds[10], { from: account_one });
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
            //accounts[9] -approved for tokenIds[7] will transfer the token to itself
            let tx = await contractInstance.transferFrom(accounts[8], accounts[9], tokensIds[7], { from: accounts[8] });
            truffleAssert.eventEmitted(tx, 'Transfer', (ev) => {
                return expect(ev.from).to.deep.equal(accounts[8])
                    && expect(ev.to).to.equal(accounts[9])
                    && expect(Number(ev.tokenId)).to.equal(tokensIds[7]);
            });

            expect(await contractInstance.ownerOf(tokensIds[7])).to.equal(accounts[9]);
            expect(Number(await contractInstance.balanceOf(accounts[9]))).to.equal(2);
            expect(Number(await contractInstance.balanceOf(accounts[8]))).to.equal(0);
            expect(await contractInstance.getApproved(tokensIds[7])).to.equal(zeroAddress);
        })
    });

    describe('have ownership properties', async () => {
        beforeEach(async () => {
            this.contract = await ERC721MintableComplete.new({ from: account_one });
        })

        // it('should fail when minting when address is not contract owner', async function () {
        //     await expectToRevert(await contractInstance.mint(account_two, 12, { from: account_one }), 'Caller is not the contract owner');
        // })

        it('should return contract owner', async () => {
            expect(await contractInstance.owner({ from: account_two })).to.equal(currentOwner);;
        })

    });
});

const expectToRevert = (promise, errorMessage) => {
    return truffleAssert.reverts(promise, errorMessage);
};