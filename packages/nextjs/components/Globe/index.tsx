"use client";

import dynamic from "next/dynamic";

// Prevent SSR for the globe component (Three.js requires browser APIs)
const OpenAIDGlobe = dynamic(() => import("./OpenAIDGlobe"), {
  ssr: false,
  loading: () => (
    <div className="w-full h-[500px] flex items-center justify-center bg-gradient-to-b from-slate-900 to-slate-800 rounded-2xl">
      <div className="flex flex-col items-center gap-4">
        <span className="loading loading-spinner loading-lg text-primary"></span>
        <span className="text-white/70">Loading Global Aid Map...</span>
      </div>
    </div>
  ),
});

export default OpenAIDGlobe;
