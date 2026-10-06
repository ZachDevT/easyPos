import { useEffect, useState } from 'react';
import { supabase } from '../supabase';
import { useNavigate } from 'react-router-dom';

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

  if (!profile) return <div className="min-h-screen flex items-center justify-center">Loading...</div>;

  return (
    <div className="min-h-screen bg-[#FBFBFD]">
      <header className="bg-white border-b border-gray-200 h-16 flex items-center justify-between px-8">
        <div className="font-bold tracking-tight flex items-center gap-2">
          <div className="w-8 h-8 bg-yellow-400 rounded-lg flex items-center justify-center">
            <span className="text-white">Y</span>
          </div>
          {profile.boutiques?.name}
        </div>
        <button onClick={logout} className="text-sm font-medium text-gray-500 hover:text-gray-900">Sign Out</button>
      </header>
      <main className="p-8 max-w-7xl mx-auto">
        <h1 className="text-3xl font-bold tracking-tight mb-8">Dashboard</h1>
        <div className="bg-white p-8 rounded-3xl border border-gray-200 shadow-sm">
          <p className="text-gray-500 mb-4">Welcome to your online admin portal. Since you are an admin, you can see all analytics here.</p>
          <div className="bg-yellow-50 text-yellow-800 p-4 rounded-xl text-sm font-medium">
            <strong>Boutique ID:</strong> {profile.boutique_id}
          </div>
          <p className="text-sm text-gray-400 mt-4">
            Use this Boutique ID inside the Yellow Pos Desktop App to sync your local store with this cloud dashboard.
          </p>
        </div>
      </main>
    </div>
  );
}
