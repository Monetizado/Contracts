# Monetizado - Contracts

Monetizado is an on-chain pay-per-view platform that allows you to monetize any web page and static content (if you don't have access to the backend to make changes) through Web3.

With Monetizado, you can implement it on news sites, social networks, exclusive content portals, and more. You could also use it to incentivize users to pay not to see advertising on your sites.

Demo: https://monetizado.github.io/demosmonetizado/demo.html

## Features
Monetizado allows you to:
- Specify protected content with a specific amount that users must pay to access.
- Review the protected content you have created.
- To your followers/users, pay to see your content.
- Check if a user has access to your content.
- Change the cost of access to content if required.
- Unprotect the content (if you want to release it to everyone for some time).
- Withdraw the money collected for your content.

## Use case
You can use monetized to protect pages so that only subscribers can see it, as in:
- News portals.
- Videos.
- Audios.
- Files
- Blogs.
- Social networks.
- And much more.

**You can protect each page individually (each with its own ID, which you will see later in this document) and the user must pay to view each page, or all are classified under the same ID, so the user only pays once to view different pages. It's your decision as a content creator.**

## Limitations
- For now, it only allows you to specify and pay with the native currency of the Blockchain network used (more tokens will be added for the new version).
- You can implement Monetizado from the Smart contract or Javascript library (there is no website yet, it will be available soon).
- In future versions, it will be enabled so that hosting (which stores the creators' pages) can charge a fee as well. Thus, the creator decides to implement his or her own content or use an external provider.

## Contract Ids
Monetizado is implemented in different Blockchain networks, below is the Id of each contract that you can use:

### Testnet

| Network | ContractId |
| -------- | ------- |
| opBnB Chain | [0x0702B45d590372b5456BeC39e13a46c00Fc8F733](https://testnet.opbnbscan.com/address/0x0702B45d590372b5456BeC39e13a46c00Fc8F733) |
| BnB Chain | [0x13cbEaAaBcC8a126dF2f7b1aA955251574191231](https://testnet.bscscan.com/address/0x13cbEaAaBcC8a126dF2f7b1aA955251574191231) |

## Use Monetizado
Now we explain how to use Monetizado, both the smart contract (backend) and the Javascript library that you can implement on any Web platform in the frontend:

Now we explain about version 1 of Monetizado, explaining how to implement it in the backend of your platform through smart contracts, or in the frontend directly if you have a static site/content.

### Smart contracts

#### Add protected Content
Indicates the content to be protected, giving a name and an amount (in the network's native currency, always in wei format), and returns a content Id (a sequential number associated with the creator's address).
```
function addProtectedContent(string memory name, uint256 accessCost) public returns (uint256)
```

Having the generated Id, plus the address of the content creator (msg.sender), it can be used in the following methods to view or pay for content.

#### Get Protected Contents For Current User
List all content protected by the content creator calling this method (msg.sender)

```
struct ProtectedContentInfo {
        string name;
        uint256 accessCost;
        bool isProtected;
        uint256 sequenceId;
        address creator;
        uint256 amountAvailable;
        uint256 amountCollected;
    }

function getProtectedContentsForCurrentUser() public view returns (ProtectedContentInfo[] memory)
```

In _ProtectedContentInfo_, _accessCost_ represents the cost (in wei) for the content that must be paid by users, _isProtected_ if the content is protected, _sequenceId_ is the sequential Id that you must use to distinguish the different contents of a creator, _amountAvailable_ is the amount that the creator has available to withdraw, and _amountCollected_ is the total amount that the creator has obtained for this content.

#### Get Protected Contents For Address and Id
Returns content protected by a specified content creator and Id
```
function getProtectedContentByAddressAndId(address creator, uint256 sequenceId) public view returns (ProtectedContentInfo memory)
```

#### Pay for content
A user (msg.sender) pays for the content they want to access, specifying the creator Id (address) and the sequential Id of the content.
```
function payAccess(address creator, uint256 sequenceId) external payable
```

In the value (msg.value) the exact value of the content must be specified (in new versions the amount may be dynamic), and the content must be protected (if it is not, it is not paid).

#### Current User Has Access
Checks if the current user (msg.sender) has access to a creator's specific content.

```
function currentUserHasAccess(address creator, uint256 sequenceId) public view returns(bool)
```

#### Change Access Cost
You can change the cost of access to specific content. You must be the creator to be able to change the cost.

```
function changeAccessCost(uint256 sequenceId, uint256 newCost) external
```

#### Unprotect Content
Unprotect content if you want content to be released to everyone.

```
function unprotectContent(uint256 sequenceId) external
```

#### Protect Content
Protect content if you want content to collect money from that.

```
function protectContent(uint256 sequenceId) external
```

#### Change Platform Fee
Specify the amount that the platform manager (in this case, Monetizado) receives as a fee for managing the contract and infrastructure, between 0.01 to 1%, but in numbers you must specify 1 (for 0.01) to 100 (1%).

```
function changePlatformFee(uint256 feePlatform) external onlyOwner
```

#### Withdraw Money From Content
The content creator can withdraw money from their content, specifying the ID and the amount they wish to withdraw (a discount is made for the platform fee from this amount).

```
function withdrawMoneyFromContent(uint256 sequenceId,uint256 amount) external
```

#### Get Platform Fee
You can see the platform fee percentage, 1 (for 0.01) to 100 (1%).

```
function getPlatformFee() public view returns(uint256)
```

#### Get Platform Balance
You can see the platform balance (collected from withdraws of creators).

```
function getPlatformBalance() public view returns(uint256)
```

#### Withdraw Money Platform
The owner of the contract can withdraw the money available as fees collected from the creation of content.

```
function withdrawMoneyPlatform(uint256 amount) external onlyOwner
```

### Frontend
To use Monetized from the frontend (if you don't have access to the backend or have static content), you can use the available Javascript library.

### ABI
If you need the API, that is available in the ABI folder in this repo.

