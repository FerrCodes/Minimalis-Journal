class PresetImages {
  static const List<Map<String, String>> images = [
    {
      'name': 'Forest',
      'url':
          'https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?q=80&w=800&auto=format&fit=crop',
    },
    {
      'name': 'Ocean',
      'url':
          'https://images.unsplash.com/photo-1505142468610-359e7d316be0?q=80&w=800&auto=format&fit=crop',
    },
    {
      'name': 'Mountain',
      'url':
          'https://images.unsplash.com/photo-1454496522488-7a8e488e8606?q=80&w=800&auto=format&fit=crop',
    },
    {
      'name': 'Sky',
      'url':
          'https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?q=80&w=800&auto=format&fit=crop',
    },
    {
      'name': 'Flowers',
      'url':
          'https://images.unsplash.com/photo-1490750967868-88aa4486c946?q=80&w=800&auto=format&fit=crop',
    },
    {
      'name': 'Abstract',
      'url':
          'https://images.unsplash.com/photo-1550684376-efcbd6e3f031?q=80&w=800&auto=format&fit=crop',
    },
    {
      'name': 'Night',
      'url':
          'https://images.unsplash.com/photo-1532978379173-523e16f371f9?q=80&w=800&auto=format&fit=crop',
    },
    {
      'name': 'Desert',
      'url':
          'https://images.unsplash.com/photo-1509316785289-025f5b846b35?q=80&w=800&auto=format&fit=crop',
    },
  ];

  static String getDefault() => images[0]['url']!;
}
