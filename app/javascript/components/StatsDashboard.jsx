import React from 'react';

export default function StatsDashboard({ politicians, stats }) {
  const politiciansWithConvictions = politicians.filter(p => p.convictions && p.convictions.length > 0).length;
  const totalConvictions = politicians.reduce((sum, p) => sum + (p.convictions?.length || 0), 0);
  const convictionRate = politicians.length > 0
    ? ((politiciansWithConvictions / politicians.length) * 100).toFixed(1)
    : 0;

  // Calculate by party
  const byParty = stats?.by_party || {};
  const topParties = Object.entries(byParty)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 3);

  return (
    <div className="bg-white rounded-lg shadow-md p-6 mb-6">
      <h2 className="text-2xl font-bold mb-6 text-gray-800">Vue d'ensemble</h2>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        {/* Total Politicians */}
        <div className="bg-blue-50 rounded-lg p-4 border-l-4 border-blue-500">
          <div className="text-blue-600 text-sm font-semibold uppercase tracking-wide mb-1">
            Total Élus
          </div>
          <div className="text-3xl font-bold text-gray-900">
            {politicians.length}
          </div>
          <div className="text-xs text-gray-600 mt-1">
            Députés et eurodéputés
          </div>
        </div>

        {/* Politicians with Convictions */}
        <div className="bg-red-50 rounded-lg p-4 border-l-4 border-red-500">
          <div className="text-red-600 text-sm font-semibold uppercase tracking-wide mb-1">
            Avec Condamnation
          </div>
          <div className="text-3xl font-bold text-gray-900">
            {politiciansWithConvictions}
          </div>
          <div className="text-xs text-gray-600 mt-1">
            {convictionRate}% des élus
          </div>
        </div>

        {/* Total Convictions */}
        <div className="bg-orange-50 rounded-lg p-4 border-l-4 border-orange-500">
          <div className="text-orange-600 text-sm font-semibold uppercase tracking-wide mb-1">
            Total Condamnations
          </div>
          <div className="text-3xl font-bold text-gray-900">
            {totalConvictions}
          </div>
          <div className="text-xs text-gray-600 mt-1">
            Toutes juridictions
          </div>
        </div>

        {/* Average per Politician */}
        <div className="bg-purple-50 rounded-lg p-4 border-l-4 border-purple-500">
          <div className="text-purple-600 text-sm font-semibold uppercase tracking-wide mb-1">
            Moyenne
          </div>
          <div className="text-3xl font-bold text-gray-900">
            {politiciansWithConvictions > 0
              ? (totalConvictions / politiciansWithConvictions).toFixed(1)
              : 0}
          </div>
          <div className="text-xs text-gray-600 mt-1">
            Par élu condamné
          </div>
        </div>
      </div>

      {/* Top Parties by Convictions */}
      {topParties.length > 0 && (
        <div className="mt-6 pt-6 border-t border-gray-200">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">
            Partis avec le plus de condamnations
          </h3>
          <div className="space-y-3">
            {topParties.map(([party, count], index) => (
              <div key={party} className="flex items-center">
                <div className="w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center mr-3 font-bold text-sm">
                  {index + 1}
                </div>
                <div className="flex-1">
                  <div className="flex justify-between items-center">
                    <span className="font-semibold text-gray-800">{party}</span>
                    <span className="text-gray-600">{count} condamnation{count > 1 ? 's' : ''}</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2 mt-1">
                    <div
                      className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                      style={{ width: `${(count / Math.max(...Object.values(byParty))) * 100}%` }}
                    ></div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
