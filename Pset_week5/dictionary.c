// Implements a dictionary's functionality

#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <stdio.h>
#include <ctype.h>
#include "dictionary.h"

// Represents a node in a hash table
typedef struct node
{
    char word[LENGTH + 1];
    struct node *next;
}
node;

// Number of buckets in hash table
const unsigned int N = 1000000;

// Value to count word loaded
unsigned int word_count = 0;

// Hash table
node *table[N];

// Returns true if word is in dictionary, else false
bool check(const char *word)
{
    // Hash the word to obtain the index
    unsigned int index = hash(word);
    
    // Loop to traverse L.L.
    for (node *tmp = table[index]; tmp != NULL; tmp = tmp->next)
    {
        if (strcasecmp(tmp->word, word) == 0)
        {
            return true;
        }
    }
    
    return false;
}

// Hashes word to a number, hash function djb2 (http://www.cse.yorku.ca/~oz/hash.html)
unsigned int hash(const char *word)
{
    unsigned long hash = 5381;
    int c;

    while ((c = toupper(*word++)))
    {
        hash = ((hash << 5) + hash) + c;
    }

    return hash % N;
}

// Loads dictionary into memory, returning true if successful, else false
bool load(const char *dictionary)
{
    // Open Dictionary And Check If File Opens Correctly
    FILE *fp = fopen(dictionary, "r");
    if (fp == NULL)
    {
        printf("File can't be opened.\n");
        fclose(fp);
        return false;
    }
    
    // Initializing a buffer to store each word
    char buffer[LENGTH + 1];
    
    // Loop To Iterate Through All Words On Dictionary
    while (fscanf(fp, "%s", buffer) != EOF)
    {
        // Creating a new node for the L.L.
        node *n = malloc(sizeof(node));
        if (n == NULL)
        {
            printf("Could not allocate memory.\n");
            free(n);
            fclose(fp);
            return false;
        }
        
        // Setting node value
        strcpy(n->word, buffer);
        n->next = NULL;
        
        // Hashing the word 
        unsigned int index = hash(n->word);
        
        // Putting the node into L.L.
        n->next = table[index];
        table[index] = n;
        word_count++;
        
    }

    fclose(fp);
    return true;
}

// Returns number of words in dictionary if loaded, else 0 if not yet loaded
unsigned int size(void)
{
    if (word_count > 0)
    {
        return word_count;
    }
    else
    {
        return 0;
    }
}

// Unloads dictionary from memory, returning true if successful, else false
bool unload(void)
{
    // Iterate throught hash table items
    for (int i = 0; i < N; i++)
    {
        // Creating a cursor to store the value of L.L.
        node *cursor = table [i];
        
        // Freeing memory if cursor is not NULL
        while (cursor != NULL)
        {
            node *tmp = cursor;
            cursor = cursor->next;
            free(tmp);
        }
        
        if (i == N - 1 && cursor == NULL)
        {
            return true;
        }
    }
    
    return false;
}
