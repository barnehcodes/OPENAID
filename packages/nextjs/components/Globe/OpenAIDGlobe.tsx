"use client";

import { useEffect, useRef, useState } from "react";
import Globe from "react-globe.gl";

interface CrisisPoint {
  lat: number;
  lng: number;
  size: number;
  color: string;
  label: string;
}

interface AidArc {
  startLat: number;
  startLng: number;
  endLat: number;
  endLng: number;
  color: string;
}

const OpenAIDGlobe = () => {
  const globeRef = useRef<any>(0);
  const [crisisPoints, setCrisisPoints] = useState<CrisisPoint[]>([]);
  const [aidArcs, setAidArcs] = useState<AidArc[]>([]);
  const [globeReady, setGlobeReady] = useState(false);

  // Sample crisis data - replace with real contract data later
  useEffect(() => {
    // Crisis locations (humanitarian emergencies)
    setCrisisPoints([
      { lat: 33.9391, lng: 67.71, size: 0.6, color: "#ff4444", label: "Afghanistan" },
      { lat: 15.5007, lng: 32.5599, size: 0.5, color: "#ff6644", label: "Sudan" },
      { lat: 6.4281, lng: 3.4219, size: 0.4, color: "#ff8844", label: "Nigeria" },
      { lat: 15.87, lng: 100.9925, size: 0.35, color: "#ffaa44", label: "Myanmar" },
      { lat: 13.7563, lng: 100.5018, size: 0.3, color: "#ffcc44", label: "Thailand" },
      { lat: -6.2088, lng: 106.8456, size: 0.25, color: "#ffdd44", label: "Indonesia" },
    ]);

    // Aid flow arcs (from donor countries to crisis zones)
    setAidArcs([
      // UK to Afghanistan
      { startLat: 51.5074, startLng: -0.1278, endLat: 33.9391, endLng: 67.71, color: "#44ff88" },
      // USA to Sudan
      { startLat: 40.7128, startLng: -74.006, endLat: 15.5007, endLng: 32.5599, color: "#44ff88" },
      // Japan to Myanmar
      { startLat: 35.6762, startLng: 139.6503, endLat: 15.87, endLng: 100.9925, color: "#44ff88" },
      // Germany to Nigeria
      { startLat: 52.52, startLng: 13.405, endLat: 6.4281, endLng: 3.4219, color: "#44ff88" },
      // Australia to Indonesia
      { startLat: -33.8688, startLng: 151.2093, endLat: -6.2088, endLng: 106.8456, color: "#44ff88" },
    ]);
  }, []);

  // Auto-rotate and configure globe
  useEffect(() => {
    if (globeRef.current && globeReady) {
      const controls = globeRef.current.controls();
      controls.autoRotate = true;
      controls.autoRotateSpeed = 0.5;
      controls.enableZoom = true;
      controls.minDistance = 200;
      controls.maxDistance = 500;
      globeRef.current.pointOfView({ altitude: 2.5 });
    }
  }, [globeReady]);

  return (
    <div className="w-full h-[500px] relative rounded-2xl overflow-hidden bg-gradient-to-b from-slate-900 to-slate-800">
      <Globe
        ref={globeRef}
        onGlobeReady={() => setGlobeReady(true)}
        globeImageUrl="//unpkg.com/three-globe/example/img/earth-blue-marble.jpg"
        bumpImageUrl="//unpkg.com/three-globe/example/img/earth-topology.png"
        backgroundImageUrl="//unpkg.com/three-globe/example/img/night-sky.png"
        // Crisis points
        pointsData={crisisPoints}
        pointLat="lat"
        pointLng="lng"
        pointColor="color"
        pointAltitude={0.01}
        pointRadius="size"
        pointLabel="label"
        // Aid flow arcs
        arcsData={aidArcs}
        arcStartLat="startLat"
        arcStartLng="startLng"
        arcEndLat="endLat"
        arcEndLng="endLng"
        arcColor="color"
        arcDashLength={0.4}
        arcDashGap={0.2}
        arcDashAnimateTime={1500}
        arcStroke={0.5}
        // Atmosphere
        atmosphereColor="#3a8ee6"
        atmosphereAltitude={0.25}
        // Size
        width={typeof window !== "undefined" ? Math.min(window.innerWidth - 40, 900) : 800}
        height={500}
      />

      {/* Legend */}
      <div className="absolute bottom-4 left-4 bg-base-200/90 backdrop-blur-sm p-4 rounded-xl shadow-lg">
        <h4 className="font-bold text-sm mb-3 text-base-content">Live Aid Map</h4>
        <div className="flex flex-col gap-2">
          <div className="flex items-center gap-2 text-xs">
            <span className="w-3 h-3 rounded-full bg-red-500 animate-pulse"></span>
            <span className="text-base-content/80">Active Crisis</span>
          </div>
          <div className="flex items-center gap-2 text-xs">
            <span className="w-8 h-0.5 bg-green-400"></span>
            <span className="text-base-content/80">Aid Flow</span>
          </div>
        </div>
      </div>

      {/* Stats overlay */}
      <div className="absolute top-4 right-4 bg-base-200/90 backdrop-blur-sm p-4 rounded-xl shadow-lg">
        <div className="text-2xl font-bold text-primary">{crisisPoints.length}</div>
        <div className="text-xs text-base-content/70">Active Crises</div>
      </div>
    </div>
  );
};

export default OpenAIDGlobe;
