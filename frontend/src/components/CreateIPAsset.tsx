import { useState } from 'react';
import { contractService } from '../services/contractService';

export const CreateIPAsset = () => {
    const [formData, setFormData] = useState({
        title: '',
        description: '',
        category: '',
        tokenURI: '',
        licenseFee: '',
        licenseTerms: ''
    });
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [success, setSuccess] = useState<string | null>(null);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsSubmitting(true);
        setError(null);
        setSuccess(null);

        try {
            const tx = await contractService.createIPAsset(
                formData.title,
                formData.description,
                formData.category,
                formData.tokenURI,
                formData.licenseFee,
                formData.licenseTerms
            );
            setSuccess(`IP Asset created successfully! Transaction hash: ${tx.hash}`);
            setFormData({
                title: '',
                description: '',
                category: '',
                tokenURI: '',
                licenseFee: '',
                licenseTerms: ''
            });
        } catch (error) {
            setError(error instanceof Error ? error.message : 'Failed to create IP asset');
        } finally {
            setIsSubmitting(false);
        }
    };

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
    };

    return (
        <div className="max-w-2xl mx-auto p-6 bg-white rounded-lg shadow-lg">
            <h2 className="text-2xl font-bold mb-6">Create New IP Asset</h2>
            <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                    <label className="block text-sm font-medium text-gray-700">Title</label>
                    <input
                        type="text"
                        name="title"
                        value={formData.title}
                        onChange={handleChange}
                        required
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                </div>

                <div>
                    <label className="block text-sm font-medium text-gray-700">Description</label>
                    <textarea
                        name="description"
                        value={formData.description}
                        onChange={handleChange}
                        required
                        rows={3}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                </div>

                <div>
                    <label className="block text-sm font-medium text-gray-700">Category</label>
                    <input
                        type="text"
                        name="category"
                        value={formData.category}
                        onChange={handleChange}
                        required
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                </div>

                <div>
                    <label className="block text-sm font-medium text-gray-700">Token URI</label>
                    <input
                        type="text"
                        name="tokenURI"
                        value={formData.tokenURI}
                        onChange={handleChange}
                        required
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                </div>

                <div>
                    <label className="block text-sm font-medium text-gray-700">License Fee (ETH)</label>
                    <input
                        type="number"
                        name="licenseFee"
                        value={formData.licenseFee}
                        onChange={handleChange}
                        required
                        step="0.000000000000000001"
                        min="0"
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                </div>

                <div>
                    <label className="block text-sm font-medium text-gray-700">License Terms</label>
                    <textarea
                        name="licenseTerms"
                        value={formData.licenseTerms}
                        onChange={handleChange}
                        required
                        rows={3}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                </div>

                <button
                    type="submit"
                    disabled={isSubmitting}
                    className="w-full py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
                >
                    {isSubmitting ? 'Creating...' : 'Create IP Asset'}
                </button>

                {error && (
                    <p className="text-red-500 text-sm">{error}</p>
                )}
                {success && (
                    <p className="text-green-500 text-sm">{success}</p>
                )}
            </form>
        </div>
    );
}; 