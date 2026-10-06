import { useEffect, useState } from 'react';
import { supabase } from '../supabase';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';

export default function Dashboard() {
  const navigate = useNavigate();
  const [profile, setProfile] = useState<any>(null);

  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (!user) {
        navigate('/login');
      } else {
        fetchProfile(user.id);
      }
    });
  }, [navigate]);

  const fetchProfile = async (userId: string) => {
    const { data } = await supabase.from('profiles').select('*, boutiques(name)').eq('id', userId).single();
    setProfile(data);
  };

  const logout = async () => {
    await supabase.auth.signOut();
    navigate('/');
  };

  if (!profile) return (
    <div className="min-h-screen flex items-center justify-center bg-[#FBFBFD]">
      <div className="w-8 h-8 border-4 border-yellow-400 border-t-transparent rounded-full animate-spin"></div>
    </div>
  );

  return (
    <div className="min-h-screen bg-[#FBFBFD] font-sans">
      <header className="bg-white/80 backdrop-blur-xl border-b border-gray-200/60 h-16 flex items-center justify-between px-8 sticky top-0 z-50">
        <div className="font-bold tracking-tight flex items-center gap-3 text-gray-900 text-lg">
          <div className="w-8 h-8 bg-gradient-to-tr from-yellow-400 to-yellow-300 rounded-lg flex items-center justify-center shadow-sm">
            <span className="text-white">Y</span>
          </div>
          {profile.boutiques?.name}
        </div>
        <button onClick={logout} className="text-sm font-medium text-gray-500 hover:text-gray-900 transition-colors bg-gray-100 px-4 py-2 rounded-full hover:bg-gray-200">
          Se déconnecter
        </button>
      </header>
      
      <main className="p-8 max-w-7xl mx-auto pt-12">
        <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}>
          <h1 className="text-4xl font-bold tracking-tight mb-8 text-gray-900">Tableau de bord</h1>
          
          <div className="bg-white p-10 rounded-[2rem] border border-gray-100 shadow-[0_8px_30px_rgb(0,0,0,0.04)]">
            <h2 className="text-2xl font-semibold mb-4 tracking-tight">Bienvenue, Administrateur</h2>
            <p className="text-[#86868B] mb-8 font-light text-lg">
              Ceci est votre portail d'administration. Vous pourrez bientôt voir toutes vos analyses et vos stocks ici.
            </p>
            
            <div className="bg-gradient-to-r from-yellow-50 to-orange-50 border border-yellow-100/50 p-6 rounded-2xl flex flex-col gap-2">
              <span className="text-sm uppercase tracking-wider font-semibold text-yellow-600">ID de la Boutique</span>
              <code className="text-lg font-mono bg-white px-4 py-2 rounded-xl text-gray-800 shadow-sm border border-yellow-100 inline-block w-fit">
                {profile.boutique_id}
              </code>
              <p className="text-sm text-yellow-800/70 mt-2 font-medium">
                Utilisez cet ID dans l'application de bureau Yellow Pos pour synchroniser votre magasin avec ce tableau de bord cloud.
              </p>
            </div>
          </div>
        </motion.div>
      </main>
    </div>
  );
}
