"use client";

import Image from "next/image";
import Link from "next/link";
import { Address } from "@scaffold-ui/components";
import type { NextPage } from "next";
import { hardhat } from "viem/chains";
import { useAccount } from "wagmi";
import { BugAntIcon, MagnifyingGlassIcon } from "@heroicons/react/24/outline";
import { useTargetNetwork } from "~~/hooks/scaffold-eth";
import OpenAIDGlobe from "~~/components/Globe";

const Home: NextPage = () => {
  const { address: connectedAddress } = useAccount();
  const { targetNetwork } = useTargetNetwork();

  return (
    <>
      <div className="flex items-center flex-col grow pt-6">
        {/* Header Section */}
        <div className="px-5 mb-6">
          <div className="flex justify-center items-center mb-4">
            <Image src="/logo.svg" alt="OpenAID Logo" width={70} height={70} />
          </div>
          <h1 className="text-center">
            <span className="block text-4xl font-bold">
              <span className="text-primary">Open</span>AID
            </span>
          </h1>
          <p className="text-center text-base mt-3 mb-4 max-w-xl mx-auto text-base-content/70">
            Decentralized Humanitarian Aid Platform — Transparent disaster relief coordination powered by blockchain
          </p>
        </div>

        {/* Globe Section */}
        <div className="w-full max-w-4xl px-4 mb-8">
          <OpenAIDGlobe />
        </div>

        {/* Connected Address */}
        <div className="flex justify-center items-center space-x-2 flex-col mb-6">
          <p className="my-2 font-medium text-sm">Connected Address:</p>
          <Address
            address={connectedAddress}
            chain={targetNetwork}
            blockExplorerAddressLink={
              targetNetwork.id === hardhat.id ? `/blockexplorer/address/${connectedAddress}` : undefined
            }
          />
        </div>

        {/* Feature Cards */}
        <div className="grow bg-base-300 w-full px-8 py-10">
          <div className="max-w-4xl mx-auto">
            <div className="flex justify-center items-center gap-8 flex-col md:flex-row">
              <div className="flex flex-col bg-base-100 px-8 py-8 text-center items-center max-w-xs rounded-2xl shadow-lg hover:shadow-xl transition-shadow">
                <BugAntIcon className="h-8 w-8 fill-secondary mb-3" />
                <h3 className="font-semibold mb-2">Debug Contracts</h3>
                <p className="text-sm text-base-content/70 mb-3">
                  Interact with OpenAID smart contracts directly
                </p>
                <Link href="/debug" className="btn btn-primary btn-sm">
                  Open Debug
                </Link>
              </div>
              <div className="flex flex-col bg-base-100 px-8 py-8 text-center items-center max-w-xs rounded-2xl shadow-lg hover:shadow-xl transition-shadow">
                <MagnifyingGlassIcon className="h-8 w-8 fill-secondary mb-3" />
                <h3 className="font-semibold mb-2">Block Explorer</h3>
                <p className="text-sm text-base-content/70 mb-3">
                  Explore blockchain transactions and events
                </p>
                <Link href="/blockexplorer" className="btn btn-secondary btn-sm">
                  View Explorer
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Home;
