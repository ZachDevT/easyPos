import { motion } from 'framer-motion';
import { ArrowRight, Box, BarChart3, Cloud, Download } from 'lucide-react';
import { Link } from 'react-router-dom';

export default function Landing() {
  const containerVariants = {
    hidden: { opacity: 0 },
    show: {
      opacity: 1,
      transition: { staggerChildren: 0.2 }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    show: { opacity: 1, y: 0, transition: { duration: 0.6 } }
  };

  return (
    <div className="min-h-screen flex flex-col bg-[#FBFBFD] overflow-hidden">
      {/* Background glow effects */}
      <div className="absolute top-[-20%] left-[-10%] w-[50%] h-[50%] bg-yellow-100 rounded-full blur-[120px] opacity-60 pointer-events-none" />
      <div className="absolute top-[20%] right-[-10%] w-[40%] h-[40%] bg-orange-50 rounded-full blur-[120px] opacity-60 pointer-events-none" />

      {/* Navbar */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-white/70 backdrop-blur-xl border-b border-gray-200/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 bg-gradient-to-tr from-yellow-400 to-yellow-300 rounded-xl flex items-center justify-center shadow-sm">
              <span className="font-bold text-white text-xl">Y</span>
            </div>
            <span className="text-xl font-bold tracking-tight text-gray-900">Yellow Pos</span>
          </div>
          <div className="flex items-center gap-6 text-sm font-medium">
            <Link to="/login" className="text-gray-500 hover:text-gray-900 transition-colors">Se connecter</Link>
            <Link to="/register" className="bg-gray-900 text-white px-5 py-2 rounded-full hover:bg-gray-800 transition-all hover:scale-105 active:scale-95 shadow-md hover:shadow-lg">
              Commencer
            </Link>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <main className="flex-1 pt-32 pb-24 relative z-10">
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center pt-10 md:pt-20">
          <motion.div initial="hidden" animate="show" variants={containerVariants}>
            <motion.h1 
              variants={itemVariants}
              className="text-6xl md:text-8xl font-bold tracking-tighter text-[#1D1D1F] mb-6 leading-tight"
            >
              La caisse qui fonctionne,<br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-yellow-400 to-yellow-600">tout simplement.</span>
            </motion.h1>
            
            <motion.p 
              variants={itemVariants}
              className="text-xl md:text-2xl text-[#86868B] max-w-2xl mx-auto mb-10 font-light tracking-tight"
            >
              Gérez votre boutique, suivez vos ventes et synchronisez tout dans le cloud. Conçu pour le hors-ligne, connecté en permanence.
            </motion.p>
            
            <motion.div 
              variants={itemVariants}
              className="flex flex-col sm:flex-row items-center justify-center gap-4"
            >
              <Link to="/register" className="bg-gray-900 text-white px-8 py-4 rounded-full text-lg font-medium hover:bg-gray-800 transition-all shadow-lg hover:shadow-xl flex items-center gap-2 hover:scale-105 active:scale-95">
                Créer ma Boutique <ArrowRight size={20} />
              </Link>
              <a href="https://github.com/ZachDevT/easyPos/releases/download/v1.0.1/YellowPos-Windows.zip" className="bg-white/80 backdrop-blur-md text-gray-900 border border-gray-200 px-8 py-4 rounded-full text-lg font-medium hover:bg-gray-50 transition-all flex items-center gap-2 shadow-sm hover:shadow hover:scale-105 active:scale-95">
                <Download size={20} /> Télécharger l'App (Windows)
              </a>
            </motion.div>
          </motion.div>
        </section>

        {/* Feature Grid */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-32 md:mt-48 relative z-10">
          <motion.div 
            initial="hidden"
            whileInView="show"
            viewport={{ once: true, margin: "-100px" }}
            variants={containerVariants}
            className="grid md:grid-cols-3 gap-8"
          >
            <FeatureCard 
              icon={<Cloud className="w-8 h-8 text-yellow-500" />}
              title="Hors-ligne d'abord."
              description="Continuez à vendre même sans internet. Vos données se synchronisent automatiquement dès le retour de la connexion."
            />
            <FeatureCard 
              icon={<Box className="w-8 h-8 text-yellow-500" />}
              title="Gestion Magique."
              description="Suivi des stocks en temps réel, scan de codes-barres et alertes de rupture directement sur votre tableau de bord."
            />
            <FeatureCard 
              icon={<BarChart3 className="w-8 h-8 text-yellow-500" />}
              title="Analyses Pro."
              description="Des graphiques superbes et des indicateurs précis pour vous aider à comprendre votre activité et prendre de meilleures décisions."
            />
          </motion.div>
        </section>
      </main>
    </div>
  );
}

function FeatureCard({ icon, title, description }: { icon: React.ReactNode, title: string, description: string }) {
  const itemVariants = {
    hidden: { opacity: 0, y: 30 },
    show: { opacity: 1, y: 0, transition: { duration: 0.8 } }
  };

  return (
    <motion.div 
      variants={itemVariants}
      whileHover={{ y: -8, scale: 1.02 }}
      transition={{ duration: 0.3 }}
      className="bg-white/80 backdrop-blur-xl p-8 rounded-[2rem] shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-100/50 flex flex-col items-center text-center"
    >
      <div className="w-16 h-16 bg-gradient-to-br from-yellow-50 to-orange-50 rounded-2xl flex items-center justify-center mb-6 shadow-sm border border-yellow-100/50">
        {icon}
      </div>
      <h3 className="text-2xl font-semibold mb-3 tracking-tight text-gray-900">{title}</h3>
      <p className="text-[#86868B] leading-relaxed font-light">{description}</p>
    </motion.div>
  );
}
