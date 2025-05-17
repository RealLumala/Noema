import { useAddress, useDisconnect, useMetamask, useCoinbaseWallet } from "@thirdweb-dev/react";

export const WalletConnect = () => {
    const address = useAddress();
    const connectWithMetamask = useMetamask();
    const connectWithCoinbaseWallet = useCoinbaseWallet();
    const disconnectWallet = useDisconnect();

    return (
        <div className="flex flex-col items-center gap-4">
            {!address ? (
                <div className="flex gap-4">
                    <button
                        onClick={connectWithMetamask}
                        className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                    >
                        Connect MetaMask
                    </button>
                    <button
                        onClick={connectWithCoinbaseWallet}
                        className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                    >
                        Connect Coinbase Wallet
                    </button>
                </div>
            ) : (
                <div className="text-center">
                    <p className="text-sm text-gray-600">Connected Account:</p>
                    <p className="font-mono text-sm">{address}</p>
                    <button
                        onClick={disconnectWallet}
                        className="mt-2 px-4 py-1 text-sm text-red-600 hover:text-red-700"
                    >
                        Disconnect
                    </button>
                </div>
            )}
        </div>
    );
}; 