import React from 'react';

const APPEAL_STATUS_LABELS = {
  'final': 'Définitif',
  'under_appeal': 'En appel',
  'cassation': 'Cassation'
};

const POSITION_LABELS = {
  'federal_mp': 'Député fédéral',
  'mep': 'Eurodéputé'
};

export default function DetailPanel({ politician, onClose }) {
  const totalPrison = politician.convictions?.reduce((sum, c) => {
    if (c.sentence_prison) {
      const match = c.sentence_prison.match(/(\d+)/);
      return sum + (match ? parseInt(match[1]) : 0);
    }
    return sum;
  }, 0) || 0;

  const totalFines = politician.convictions?.reduce((sum, c) => {
    return sum + (parseFloat(c.sentence_fine) || 0);
  }, 0) || 0;

  return (
    <div className="border-t-4 border-red-500 bg-white shadow-lg">
      <div className="p-6 max-h-96 overflow-y-auto">
        {/* Header */}
        <div className="flex justify-between items-start mb-6">
          <div>
            <h3 className="text-2xl font-bold text-gray-900">{politician.name}</h3>
            <div className="mt-2 flex items-center space-x-4 text-sm">
              <span className="inline-flex items-center px-3 py-1 rounded-full bg-blue-100 text-blue-800 font-semibold">
                {politician.party}
              </span>
              <span className="text-gray-600">
                {POSITION_LABELS[politician.position] || politician.position}
              </span>
            </div>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-full p-2 transition-colors"
            title="Fermer"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* Summary Stats */}
        <div className="grid grid-cols-3 gap-4 mb-6 p-4 bg-red-50 rounded-lg">
          <div className="text-center">
            <div className="text-2xl font-bold text-red-600">{politician.convictions?.length || 0}</div>
            <div className="text-xs text-gray-600 uppercase">Condamnations</div>
          </div>
          {totalPrison > 0 && (
            <div className="text-center">
              <div className="text-2xl font-bold text-orange-600">{totalPrison} an{totalPrison > 1 ? 's' : ''}</div>
              <div className="text-xs text-gray-600 uppercase">Prison total</div>
            </div>
          )}
          {totalFines > 0 && (
            <div className="text-center">
              <div className="text-2xl font-bold text-green-600">€{totalFines.toLocaleString()}</div>
              <div className="text-xs text-gray-600 uppercase">Amendes totales</div>
            </div>
          )}
        </div>

        {/* Convictions List */}
        <div className="space-y-4">
          <h4 className="text-lg font-semibold text-gray-900 mb-3">
            Détail des condamnations
          </h4>
          {politician.convictions?.map((conviction, index) => (
            <div key={conviction.id} className="bg-gray-50 rounded-lg p-4 border-l-4 border-red-500">
              <div className="flex justify-between items-start mb-2">
                <div>
                  <span className="inline-block px-2 py-1 text-xs font-semibold bg-red-100 text-red-800 rounded">
                    #{index + 1}
                  </span>
                </div>
                <div className="text-right text-sm text-gray-600">
                  {new Date(conviction.conviction_date).toLocaleDateString('fr-BE', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                  })}
                </div>
              </div>

              <p className="font-semibold text-gray-900 text-lg mb-2 capitalize">
                {conviction.offense_type}
              </p>

              {conviction.description && (
                <p className="text-sm text-gray-700 mb-3 leading-relaxed">
                  {conviction.description}
                </p>
              )}

              <div className="grid grid-cols-2 gap-3 text-sm">
                {conviction.sentence_prison && (
                  <div className="flex items-center space-x-2">
                    <svg className="w-4 h-4 text-orange-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                    </svg>
                    <span className="text-gray-700">
                      <strong>Prison:</strong> {conviction.sentence_prison}
                    </span>
                  </div>
                )}

                {conviction.sentence_fine && (
                  <div className="flex items-center space-x-2">
                    <svg className="w-4 h-4 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    <span className="text-gray-700">
                      <strong>Amende:</strong> €{parseFloat(conviction.sentence_fine).toLocaleString()}
                    </span>
                  </div>
                )}

                {conviction.sentence_ineligibility && (
                  <div className="col-span-2 flex items-center space-x-2">
                    <svg className="w-4 h-4 text-purple-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636" />
                    </svg>
                    <span className="text-gray-700">
                      <strong>Inéligibilité:</strong> {conviction.sentence_ineligibility}
                    </span>
                  </div>
                )}
              </div>

              <div className="mt-3 pt-3 border-t border-gray-200 flex justify-between items-center">
                <span className={`text-xs px-2 py-1 rounded ${
                  conviction.appeal_status === 'final'
                    ? 'bg-red-100 text-red-700'
                    : 'bg-yellow-100 text-yellow-700'
                }`}>
                  {APPEAL_STATUS_LABELS[conviction.appeal_status] || conviction.appeal_status}
                </span>

                {conviction.verified && (
                  <span className="text-xs flex items-center text-green-600">
                    <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                    </svg>
                    Vérifié
                  </span>
                )}
              </div>

              {conviction.source_url && (
                <div className="mt-2">
                  <a
                    href={conviction.source_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-xs text-blue-600 hover:text-blue-800 hover:underline flex items-center"
                  >
                    <svg className="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                    </svg>
                    Source
                  </a>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
