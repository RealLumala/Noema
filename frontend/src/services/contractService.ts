import { useContract, useContractRead, useContractWrite } from "@thirdweb-dev/react";
import { ethers } from "ethers";
import { CoinbaseWalletSDK } from '@coinbase/wallet-sdk';
import contractABI from '../contracts/NoemaIP.json';

const CONTRACT_ADDRESS = import.meta.env.VITE_CONTRACT_ADDRESS;

export interface IPAsset {
    title: string;
    description: string;
    category: string;
    creator: string;
    creationDate: number;
    isLicensed: boolean;
    licenseFee: number;
    licenseTerms: string;
}

export const useNoemaIPContract = () => {
    const { contract } = useContract(CONTRACT_ADDRESS, contractABI.abi);

    const { data: ipAsset, isLoading: isLoadingIPAsset } = useContractRead(
        contract,
        "getIPAsset",
        []
    );

    const { mutateAsync: createIPAsset } = useContractWrite(
        contract,
        "createIPAsset"
    );

    const { mutateAsync: grantLicense } = useContractWrite(
        contract,
        "grantLicense"
    );

    const { mutateAsync: revokeLicense } = useContractWrite(
        contract,
        "revokeLicense"
    );

    const { data: creatorAssets, isLoading: isLoadingCreatorAssets } = useContractRead(
        contract,
        "getCreatorAssets",
        []
    );

    const { data: licensees, isLoading: isLoadingLicensees } = useContractRead(
        contract,
        "getLicensees",
        []
    );

    return {
        contract,
        ipAsset,
        isLoadingIPAsset,
        createIPAsset,
        grantLicense,
        revokeLicense,
        creatorAssets,
        isLoadingCreatorAssets,
        licensees,
        isLoadingLicensees,
    };
};

class ContractService {
    private contract: ethers.Contract | null = null;
    private provider: ethers.providers.Web3Provider | null = null;
    private signer: ethers.Signer | null = null;
    private coinbaseWallet: CoinbaseWalletSDK | null = null;

    async initialize(wallet: CoinbaseWalletSDK) {
        this.coinbaseWallet = wallet;
        const provider = wallet.makeWeb3Provider();
        this.provider = new ethers.providers.Web3Provider(provider);
        this.signer = await this.provider.getSigner();
        if (!this.signer) throw new Error('Failed to get signer');
        
        this.contract = new ethers.Contract(
            CONTRACT_ADDRESS,
            contractABI.abi,
            this.signer
        );
    }

    async createIPAsset(
        title: string,
        description: string,
        category: string,
        tokenURI: string,
        licenseFee: string,
        licenseTerms: string
    ) {
        if (!this.contract) throw new Error('Contract not initialized');
        
        const fee = ethers.utils.parseEther(licenseFee);
        const tx = await this.contract.createIPAsset(
            title,
            description,
            category,
            tokenURI,
            fee,
            licenseTerms
        );
        return await tx.wait();
    }

    async grantLicense(tokenId: number, licenseFee: string) {
        if (!this.contract) throw new Error('Contract not initialized');
        
        const fee = ethers.utils.parseEther(licenseFee);
        const tx = await this.contract.grantLicense(tokenId, { value: fee });
        return await tx.wait();
    }

    async revokeLicense(tokenId: number, licensee: string) {
        if (!this.contract) throw new Error('Contract not initialized');
        
        const tx = await this.contract.revokeLicense(tokenId, licensee);
        return await tx.wait();
    }

    async getIPAsset(tokenId: number): Promise<IPAsset> {
        if (!this.contract) throw new Error('Contract not initialized');
        
        const asset = await this.contract.getIPAsset(tokenId);
        return {
            title: asset.title,
            description: asset.description,
            category: asset.category,
            creator: asset.creator,
            creationDate: Number(asset.creationDate),
            isLicensed: asset.isLicensed,
            licenseFee: Number(asset.licenseFee),
            licenseTerms: asset.licenseTerms
        };
    }

    async getCreatorAssets(creator: string): Promise<number[]> {
        if (!this.contract) throw new Error('Contract not initialized');
        
        const assets = await this.contract.getCreatorAssets(creator);
        return assets.map((asset: bigint) => Number(asset));
    }

    async getLicensees(tokenId: number): Promise<string[]> {
        if (!this.contract) throw new Error('Contract not initialized');
        
        return await this.contract.getLicensees(tokenId);
    }
}

export const contractService = new ContractService(); 