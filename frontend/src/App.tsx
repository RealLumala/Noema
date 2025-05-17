import { ThirdwebProvider } from "@thirdweb-dev/react";
import { Base } from "@thirdweb-dev/chains";
import { WalletConnect } from './components/WalletConnect'
//import { CreateIPAsset } from './components/CreateIPAsset'
import { IPAssetList } from './components/IPAssetList'
import './App.css'

function App() {
  return (
    <ThirdwebProvider
      activeChain={Base}
      clientId={import.meta.env.VITE_THIRDWEB_CLIENT_ID}
    >
      <div className="min-h-screen bg-gray-100">
        <header className="bg-white shadow">
          <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
            <h1 className="text-3xl font-bold text-gray-900">NoemaIP</h1>
          </div>
        </header>
        <main>
          <div className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
            <div className="px-4 py-6 sm:px-0">
              <WalletConnect />
              <div className="mt-8">
                <IPAssetList />
              </div>
            </div>
          </div>
        </main>
      </div>
    </ThirdwebProvider>
  )
}

export default App
