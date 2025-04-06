import React, { useState, useEffect, useRef } from 'react';
import { 
  TextField, 
  Autocomplete, 
  Paper, 
  Typography, 
  Box, 
  CircularProgress,
  Chip,
  Divider,
  List,
  ListItem,
  ListItemText
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import InputAdornment from '@mui/material/InputAdornment';
import searchApi, { 
  AutocompleteSuggestion, 
  SpellingSuggestion,
  SearchResult
} from '../api/searchApi';

interface SearchBarProps {
  onSearch: (query: string) => void;
}

const SearchBar: React.FC<SearchBarProps> = ({ onSearch }) => {
  const [inputValue, setInputValue] = useState<string>('');
  const [suggestions, setSuggestions] = useState<AutocompleteSuggestion[]>([]);
  const [spellingSuggestions, setSpellingSuggestions] = useState<SpellingSuggestion[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [open, setOpen] = useState<boolean>(false);
  const debounceTimeout = useRef<NodeJS.Timeout | null>(null);

  // Fetch autocomplete suggestions when input changes
  useEffect(() => {
    if (inputValue.trim().length < 2) {
      setSuggestions([]);
      return;
    }

    if (debounceTimeout.current) {
      clearTimeout(debounceTimeout.current);
    }

    debounceTimeout.current = setTimeout(async () => {
      setLoading(true);
      try {
        const response = await searchApi.autocomplete(inputValue);
        setSuggestions(response.suggestions);
        
        // If no suggestions found, check for spelling corrections
        if (response.suggestions.length === 0) {
          const spellingResponse = await searchApi.spellingSuggestions(inputValue);
          setSpellingSuggestions(spellingResponse.suggestions);
        } else {
          setSpellingSuggestions([]);
        }
      } catch (error) {
        console.error('Error fetching suggestions:', error);
      } finally {
        setLoading(false);
      }
    }, 300);

    return () => {
      if (debounceTimeout.current) {
        clearTimeout(debounceTimeout.current);
      }
    };
  }, [inputValue]);

  const handleSearch = () => {
    if (inputValue.trim()) {
      onSearch(inputValue);
    }
  };

  const handleKeyPress = (event: React.KeyboardEvent) => {
    if (event.key === 'Enter') {
      handleSearch();
    }
  };

  const handleSuggestionClick = (suggestion: string) => {
    setInputValue(suggestion);
    onSearch(suggestion);
  };

  const handleSpellingSuggestionClick = (suggestion: string) => {
    setInputValue(suggestion);
    onSearch(suggestion);
  };

  return (
    <Box sx={{ width: '100%', maxWidth: 800, margin: '0 auto' }}>
      <Paper
        elevation={3}
        sx={{
          p: 2,
          borderRadius: 2,
          backgroundColor: '#fff',
        }}
      >
        <Typography variant="h5" gutterBottom sx={{ fontWeight: 'bold', color: '#1976d2' }}>
          Cash Management Search
        </Typography>
        
        <TextField
          fullWidth
          variant="outlined"
          placeholder="Search for payments, deposits, loans..."
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          onKeyPress={handleKeyPress}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <SearchIcon color="primary" />
              </InputAdornment>
            ),
            endAdornment: loading ? (
              <InputAdornment position="end">
                <CircularProgress color="inherit" size={20} />
              </InputAdornment>
            ) : null,
            sx: { borderRadius: 2 }
          }}
          autoComplete="off"
          onClick={() => setOpen(true)}
        />

        {open && (inputValue.length > 1) && (
          <Paper 
            sx={{ 
              mt: 1, 
              maxHeight: 300, 
              overflow: 'auto',
              borderRadius: 2,
              border: '1px solid #e0e0e0'
            }}
          >
            {suggestions.length > 0 && (
              <>
                <Typography variant="subtitle2" sx={{ p: 1, bgcolor: '#f5f5f5' }}>
                  Suggestions
                </Typography>
                <List dense>
                  {suggestions.map((suggestion, index) => (
                    <ListItem 
                      button 
                      key={index}
                      onClick={() => handleSuggestionClick(suggestion.suggestion)}
                      divider={index < suggestions.length - 1}
                    >
                      <ListItemText 
                        primary={suggestion.suggestion} 
                        secondary={`Source: ${suggestion.source}`}
                      />
                    </ListItem>
                  ))}
                </List>
              </>
            )}

            {spellingSuggestions.length > 0 && (
              <>
                <Typography variant="subtitle2" sx={{ p: 1, bgcolor: '#f5f5f5' }}>
                  Did you mean:
                </Typography>
                <Box sx={{ p: 1, display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                  {spellingSuggestions.map((suggestion, index) => (
                    <Chip
                      key={index}
                      label={suggestion.suggestion}
                      onClick={() => handleSpellingSuggestionClick(suggestion.suggestion)}
                      color="primary"
                      variant="outlined"
                      size="small"
                      sx={{ m: 0.5 }}
                    />
                  ))}
                </Box>
              </>
            )}

            {suggestions.length === 0 && spellingSuggestions.length === 0 && !loading && (
              <Typography sx={{ p: 2, textAlign: 'center', color: 'text.secondary' }}>
                No suggestions found
              </Typography>
            )}
          </Paper>
        )}
      </Paper>
    </Box>
  );
};

export default SearchBar;
