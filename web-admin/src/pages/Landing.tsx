import { motion } from 'framer-motion';
import { ArrowRight, Box, BarChart3, Cloud } from 'lucide-react';
import { Link } from 'react-router-dom';

export default function Landing() {
  return (
    <div className="min-h-screen flex flex-col">
      {/* Navbar */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-md border-b border-gray-100">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 bg-yellow-400 rounded-lg flex items-center justify-center">
              <span className="font-bold text-white text-xl">Y</span>
            </div>
            <span className="text-xl font-bold tracking-tight">Yellow Pos</span>
          </div>
          <div className="flex items-center gap-6 text-sm font-medium">
            <Link to="/login" className="text-gray-600 hover:text-gray-900 transition-colors">Sign In</Link>
            <Link to="/register" className="bg-gray-900 text-white px-5 py-2 rounded-full hover:bg-gray-800 transition-colors">
              Get Started
            </Link>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <main className="flex-1 pt-32 pb-24">
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <motion.h1 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, ease: "easeOut" }}
            className="text-6xl md:text-8xl font-bold tracking-tighter text-[#1D1D1F] mb-6"
          >
            The POS that <br />
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-yellow-400 to-yellow-600">just works.</span>
          </motion.h1>
          
          <motion.p 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2, ease: "easeOut" }}
            className="text-xl md:text-2xl text-[#86868B] max-w-2xl mx-auto mb-10 font-light tracking-tight"
          >
            Manage your boutique, track sales, and sync everything to the cloud. Offline-first, seamlessly connected.
          </motion.p>
          
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.4, ease: "easeOut" }}
            className="flex flex-col sm:flex-row items-center justify-center gap-4"
          >
            <Link to="/register" className="bg-gray-900 text-white px-8 py-4 rounded-full text-lg font-medium hover:bg-gray-800 transition-all shadow-lg hover:shadow-xl flex items-center gap-2">
              Create your Boutique <ArrowRight size={20} />
            </Link>
            <a href="#" className="bg-white text-gray-900 border border-gray-200 px-8 py-4 rounded-full text-lg font-medium hover:bg-gray-50 transition-all flex items-center gap-2">
              Download App
            </a>
          </motion.div>
        </section>

        {/* Feature Grid */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-40">
          <div className="grid md:grid-cols-3 gap-8">
            <FeatureCard 
              icon={<Cloud className="w-8 h-8 text-yellow-500" />}
              title="Offline First."
              description="Keep selling even when the internet drops. Data syncs automatically when you're back online."
            />
            <FeatureCard 
              icon={<Box className="w-8 h-8 text-yellow-500" />}
              title="Inventory Magic."
              description="Real-time stock tracking, barcode scanning, and low-stock alerts right on your dashboard."
            />
            <FeatureCard 
              icon={<BarChart3 className="w-8 h-8 text-yellow-500" />}
              title="Pro Analytics."
              description="Beautiful charts and insights to help you understand your business and make better decisions."
            />
          </div>
        </section>
      </main>
    </div>
  );
}

function FeatureCard({ icon, title, description }: { icon: React.ReactNode, title: string, description: string }) {
  return (
    <motion.div 
      whileHover={{ y: -5 }}
      className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100 flex flex-col items-center text-center"
    >
      <div className="w-16 h-16 bg-yellow-50 rounded-2xl flex items-center justify-center mb-6">
        {icon}
      </div>
      <h3 className="text-xl font-bold mb-3">{title}</h3>
      <p className="text-[#86868B]">{description}</p>
    </motion.div>
  );
}
