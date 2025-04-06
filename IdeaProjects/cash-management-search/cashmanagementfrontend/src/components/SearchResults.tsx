import React, { useState, useEffect } from 'react';
import { 
  Container, 
  Typography, 
  Box, 
  Paper, 
  Grid, 
  Card, 
  CardContent, 
  Chip,
  Pagination,
  CircularProgress,
  Divider,
  Alert
} from '@mui/material';
import SearchBar from './SearchBar';
import searchApi, { SearchResult, SearchResponse } from '../api/searchApi';

const SearchResults: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState<string>('');
  const [results, setResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [page, setPage] = useState<number>(0);
  const [totalPages, setTotalPages] = useState<number>(0);
  const [totalElements, setTotalElements] = useState<number>(0);

  const handleSearch = async (query: string) => {
    setSearchTerm(query);
    setPage(0);
    performSearch(query, 0);
  };

  const handlePageChange = (event: React.ChangeEvent<unknown>, value: number) => {
    setPage(value - 1);
    performSearch(searchTerm, value - 1);
  };

  const performSearch = async (query: string, pageNumber: number) => {
    if (!query.trim()) return;
    
    setLoading(true);
    setError(null);
    
    try {
      const response = await searchApi.search({
        query,
        page: pageNumber,
        size: 10
      });
      
      setResults(response.content);
      setTotalPages(response.totalPages);
      setTotalElements(response.totalElements);
    } catch (err) {
      console.error('Error performing search:', err);
      setError('An error occurred while searching. Please try again.');
      setResults([]);
    } finally {
      setLoading(false);
    }
  };

  const getEntityIcon = (entityType: string) => {
    switch (entityType) {
      case 'payment':
        return '💸';
      case 'deposit':
        return '💰';
      case 'loan':
        return '🏦';
      default:
        return '📄';
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const formatCurrency = (amount: number, currency: string) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: currency || 'USD'
    }).format(amount);
  };

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 8 }}>
      <Box sx={{ mb: 4 }}>
        <SearchBar onSearch={handleSearch} />
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      {loading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
          <CircularProgress />
        </Box>
      ) : (
        <>
          {searchTerm && (
            <Box sx={{ mb: 2 }}>
              <Typography variant="body2" color="text.secondary">
                {totalElements} results found for "{searchTerm}"
              </Typography>
            </Box>
          )}

          {results.length > 0 ? (
            <>
              <Grid container spacing={2}>
                {results.map((result, index) => (
                  <Grid item xs={12} key={`${result.entityType}-${result.entityId}-${index}`}>
                    <Card 
                      variant="outlined" 
                      sx={{ 
                        borderRadius: 2,
                        transition: 'all 0.2s',
                        '&:hover': {
                          boxShadow: '0 4px 8px rgba(0,0,0,0.1)',
                          transform: 'translateY(-2px)'
                        }
                      }}
                    >
                      <CardContent>
                        <Grid container spacing={2}>
                          <Grid item xs={12} sm={8}>
                            <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                              <Typography variant="h6" component="div" sx={{ mr: 1 }}>
                                {getEntityIcon(result.entityType)} {result.primaryIdentifier}
                              </Typography>
                              <Chip 
                                label={result.entityType.charAt(0).toUpperCase() + result.entityType.slice(1)} 
                                size="small" 
                                color={
                                  result.entityType === 'payment' ? 'primary' : 
                                  result.entityType === 'deposit' ? 'success' : 'warning'
                                }
                                sx={{ ml: 1 }}
                              />
                              <Chip 
                                label={result.status} 
                                size="small" 
                                variant="outlined"
                                sx={{ ml: 1 }}
                              />
                            </Box>
                            <Typography variant="body2" color="text.secondary" gutterBottom>
                              {result.partyInfo}
                            </Typography>
                            <Typography variant="body2" paragraph>
                              {result.description || 'No description available'}
                            </Typography>
                            {result.referenceNumber && (
                              <Typography variant="body2" color="text.secondary">
                                Reference: {result.referenceNumber}
                              </Typography>
                            )}
                          </Grid>
                          <Grid item xs={12} sm={4}>
                            <Box sx={{ textAlign: 'right' }}>
                              <Typography variant="h6" component="div" sx={{ color: 'primary.main' }}>
                                {formatCurrency(result.amount, result.currency)}
                              </Typography>
                              <Typography variant="body2" color="text.secondary">
                                {formatDate(result.date)}
                              </Typography>
                              <Box sx={{ mt: 1 }}>
                                <Chip 
                                  size="small" 
                                  label={`Relevance: ${Math.round(result.rank * 100)}%`}
                                  sx={{ 
                                    bgcolor: result.rank > 0.7 ? '#e3f2fd' : '#f5f5f5',
                                    fontSize: '0.7rem'
                                  }}
                                />
                              </Box>
                            </Box>
                          </Grid>
                        </Grid>
                      </CardContent>
                    </Card>
                  </Grid>
                ))}
              </Grid>

              {totalPages > 1 && (
                <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
                  <Pagination 
                    count={totalPages} 
                    page={page + 1} 
                    onChange={handlePageChange} 
                    color="primary" 
                    showFirstButton 
                    showLastButton
                  />
                </Box>
              )}
            </>
          ) : (
            searchTerm && !loading && (
              <Paper sx={{ p: 3, textAlign: 'center', borderRadius: 2 }}>
                <Typography variant="h6" color="text.secondary">
                  No results found
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Try different keywords or check your spelling
                </Typography>
              </Paper>
            )
          )}
        </>
      )}
    </Container>
  );
};

export default SearchResults;
