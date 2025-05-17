import { useState } from 'react';
import { useAddress } from "@thirdweb-dev/react";
import { useNoemaIPContract, IPAsset } from '../services/contractService';
import { ethers } from 'ethers';

export const IPAssetList = () => {
    const address = useAddress();
    const {
        creatorAssets,
        isLoadingCreatorAssets,
        createIPAsset,
        grantLicense,
        revokeLicense,
    } = useNoemaIPContract();

    const [selectedAsset, setSelectedAsset] = useState<{ id: number; asset: IPAsset } | null>(null);
    const [licenseFee, setLicenseFee] = useState('');
    const [isGrantingLicense, setIsGrantingLicense] = useState(false);

    const handleGrantLicense = async () => {
        if (!selectedAsset) return;
        
        try {
            setIsGrantingLicense(true);
            
            const fee = ethers.utils.parseEther(licenseFee);
            await grantLicense({
                args: [selectedAsset.id],
                overrides: { value: fee }
            });
            
            setSelectedAsset(null);
            setLicenseFee('');
        } catch (error) {
            console.error('Failed to grant license:', error);
        } finally {
            setIsGrantingLicense(false);
        }
    };

    if (isLoadingCreatorAssets) {
        return <div className="text-center py-4">Loading assets...</div>;
    }

    if (!creatorAssets || creatorAssets.length === 0) {
        return <p className="text-gray-500 text-center">No IP assets found</p>;
    }

    return (
        <div className="max-w-4xl mx-auto p-6">
            <h2 className="text-2xl font-bold mb-6">Your IP Assets</h2>
            
            <div className="grid gap-6">
                {creatorAssets.map((id) => (
                    <div key={id} className="bg-white rounded-lg shadow p-6">
                        <h3 className="text-xl font-semibold mb-2">Asset #{id}</h3>
                        
                        <div className="grid grid-cols-2 gap-4 mb-4">
                            <div>
                                <p className="text-sm text-gray-500">Asset ID</p>
                                <p>{id}</p>
                            </div>
                        </div>

                        <button
                            onClick={() => setSelectedAsset({ id, asset: {} as IPAsset })}
                            className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
                        >
                            Grant License
                        </button>
                    </div>
                ))}
            </div>

            {selectedAsset && (
                <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
                    <div className="bg-white rounded-lg p-6 max-w-md w-full">
                        <h3 className="text-xl font-semibold mb-4">Grant License</h3>
                        <p className="mb-4">Enter the license fee for Asset #{selectedAsset.id}</p>
                        
                        <input
                            type="number"
                            value={licenseFee}
                            onChange={(e) => setLicenseFee(e.target.value)}
                            placeholder="License fee in ETH"
                            className="w-full mb-4 p-2 border rounded"
                            step="0.000000000000000001"
                            min="0"
                        />
                        
                        <div className="flex justify-end gap-4">
                            <button
                                onClick={() => {
                                    setSelectedAsset(null);
                                    setLicenseFee('');
                                }}
                                className="px-4 py-2 text-gray-600 hover:text-gray-800"
                            >
                                Cancel
                            </button>
                            <button
                                onClick={handleGrantLicense}
                                disabled={isGrantingLicense}
                                className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 disabled:opacity-50"
                            >
                                {isGrantingLicense ? 'Granting...' : 'Grant License'}
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}; 