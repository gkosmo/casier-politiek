import React from 'react';

export default function Hemicycle({ politicians, onPoliticianClick }) {
  return (
    <div className="w-full h-full flex items-center justify-center bg-gray-50">
      <div className="text-center">
        <h3 className="text-xl mb-4">Hemicycle Visualization</h3>
        <p className="text-gray-600 mb-4">
          Showing {politicians.length} politicians with convictions
        </p>
        <div className="flex flex-wrap gap-2 justify-center max-w-4xl">
          {politicians.slice(0, 50).map(politician => (
            <button
              key={politician.id}
              onClick={() => onPoliticianClick(politician)}
              className="px-3 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 text-sm"
              title={`${politician.name} - ${politician.convictions_count} convictions`}
            >
              {politician.name.split(' ')[0]}
            </button>
          ))}
        </div>
        <p className="text-sm text-gray-500 mt-4">
          (D3.js visualization will be implemented in next task)
        </p>
      </div>
    </div>
  );
}
