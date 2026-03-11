import React from 'react';

export default function DetailPanel({ politician, onClose }) {
  return (
    <div className="border-t bg-white p-6 h-64 overflow-y-auto">
      <div className="flex justify-between items-start mb-4">
        <div>
          <h3 className="text-xl font-bold">{politician.name}</h3>
          <p className="text-gray-600">{politician.party} - {politician.position}</p>
        </div>
        <button
          onClick={onClose}
          className="text-gray-500 hover:text-gray-700"
        >
          ✕
        </button>
      </div>

      <div className="space-y-4">
        <h4 className="font-semibold">Convictions ({politician.convictions.length})</h4>
        {politician.convictions.map(conviction => (
          <div key={conviction.id} className="border-l-4 border-red-500 pl-4">
            <p className="font-medium">{conviction.offense_type}</p>
            <p className="text-sm text-gray-600">{conviction.conviction_date}</p>
            {conviction.sentence_prison && (
              <p className="text-sm">Prison: {conviction.sentence_prison}</p>
            )}
            {conviction.sentence_fine && (
              <p className="text-sm">Fine: €{conviction.sentence_fine}</p>
            )}
            <p className="text-sm mt-2">{conviction.description}</p>
            <p className="text-xs text-gray-500">Status: {conviction.appeal_status}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
