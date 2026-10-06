import { useState } from 'react';
import { supabase } from '../supabase';
import { Link, useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    setLoading(false);
    if (error) {
      alert(error.message);
    } else {
      navigate('/dashboard');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#FBFBFD] px-4 overflow-hidden relative">
      <div className="absolute top-[10%] left-[20%] w-[40%] h-[40%] bg-yellow-100/50 rounded-full blur-[100px] pointer-events-none" />
      
      <motion.div 
        initial={{ opacity: 0, y: 20, scale: 0.98 }}
        animate={{ opacity: 1, y: 0, scale: 1 }}
        transition={{ duration: 0.6 }}
        className="w-full max-w-md bg-white/80 backdrop-blur-2xl p-10 rounded-[2.5rem] shadow-[0_8px_40px_rgb(0,0,0,0.06)] border border-gray-100 relative z-10"
      >
        <div className="text-center mb-10">
          <div className="w-14 h-14 bg-gradient-to-tr from-yellow-400 to-yellow-300 rounded-[1.25rem] flex items-center justify-center mx-auto mb-6 shadow-md shadow-yellow-200/50">
            <span className="font-bold text-white text-3xl">Y</span>
          </div>
          <h1 className="text-3xl font-bold tracking-tight text-gray-900">Bon retour</h1>
          <p className="text-gray-500 mt-2 font-light">Connectez-vous à votre portail Yellow Pos</p>
        </div>

        <form onSubmit={handleLogin} className="space-y-5">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">Adresse e-mail</label>
            <input 
              type="email" 
              value={email}
              onChange={e => setEmail(e.target.value)}
              className="w-full px-5 py-4 bg-gray-50/50 rounded-2xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all"
              placeholder="nom@boutique.com"
              required 
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">Mot de passe</label>
            <input 
              type="password" 
              value={password}
              onChange={e => setPassword(e.target.value)}
              className="w-full px-5 py-4 bg-gray-50/50 rounded-2xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all"
              placeholder="••••••••"
              required 
            />
          </div>
          <button 
            type="submit" 
            disabled={loading}
            className="w-full bg-gray-900 text-white rounded-2xl py-4 font-medium hover:bg-gray-800 active:scale-[0.98] transition-all shadow-md mt-6 disabled:opacity-50"
          >
            {loading ? 'Connexion en cours...' : 'Se connecter'}
          </button>
        </form>

        <p className="text-center mt-10 text-gray-500 text-sm">
          Vous n'avez pas encore de boutique ? <Link to="/register" className="text-yellow-600 font-semibold hover:underline">En créer une</Link>
        </p>
      </motion.div>
    </div>
  );
}
