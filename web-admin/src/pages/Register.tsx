import { useState } from 'react';
import { supabase } from '../supabase';
import { Link, useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';

export default function Register() {
  const [boutiqueName, setBoutiqueName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const { data: authData, error: authError } = await supabase.auth.signUp({ email, password });
      if (authError) throw authError;

      const { data: boutiqueData, error: boutiqueError } = await supabase
        .from('boutiques')
        .insert([{ name: boutiqueName }])
        .select()
        .single();
      if (boutiqueError) throw boutiqueError;

      if (authData.user) {
        await supabase.from('profiles').insert([{
          id: authData.user.id,
          boutique_id: boutiqueData.id,
          role: 'admin'
        }]);
      }

      alert('Inscription réussie !');
      navigate('/login');
    } catch (err: any) {
      alert(err.message || 'Une erreur est survenue.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#FBFBFD] px-4 py-12 relative overflow-hidden">
      <div className="absolute bottom-[10%] right-[10%] w-[50%] h-[50%] bg-orange-100/40 rounded-full blur-[120px] pointer-events-none" />

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
          <h1 className="text-3xl font-bold tracking-tight text-gray-900">Créez votre Boutique</h1>
          <p className="text-gray-500 mt-2 font-light">Démarrez avec Yellow Pos en quelques secondes</p>
        </div>

        <form onSubmit={handleRegister} className="space-y-5">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">Nom de la Boutique</label>
            <input 
              type="text" 
              value={boutiqueName}
              onChange={e => setBoutiqueName(e.target.value)}
              className="w-full px-5 py-4 bg-gray-50/50 rounded-2xl border border-gray-200 focus:outline-none focus:ring-4 focus:ring-yellow-400/20 focus:border-yellow-400 transition-all"
              placeholder="Ma Super Boutique"
              required 
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">E-mail Administrateur</label>
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
            <label className="block text-sm font-medium text-gray-700 mb-2 ml-1">Mot de passe sécurisé</label>
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
            className="w-full bg-gray-900 text-white rounded-2xl py-4 font-medium hover:bg-gray-800 active:scale-[0.98] transition-all shadow-md mt-8 disabled:opacity-50"
          >
            {loading ? 'Création en cours...' : 'Créer le compte'}
          </button>
        </form>

        <p className="text-center mt-10 text-gray-500 text-sm">
          Vous avez déjà un compte ? <Link to="/login" className="text-yellow-600 font-semibold hover:underline">Se connecter</Link>
        </p>
      </motion.div>
    </div>
  );
}
