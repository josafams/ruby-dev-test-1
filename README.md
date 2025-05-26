# Modelos de Sistema de Arquivos

Implementação em Ruby on Rails de um sistema de arquivos hierárquico com múltiplas estratégias de armazenamento.

## Funcionalidades

- Estrutura de diretórios hierárquica  
- Múltiplos tipos de armazenamento de arquivos (blob, S3, disco)  
- Padrão Strategy para as implementações de armazenamento  
- Objetos de serviço para criação de arquivos  
- Conjunto de testes abrangente com RSpec

## Modelos

### FileSystemNode (Modelo Base)
- Classe base utilizando herança de tabela única (STI - Single Table Inheritance)  
- Suporta diretórios e arquivos  
- Estrutura hierárquica com relacionamentos pai-filho  

### Directory
- Herda de FileSystemNode  
- Pode conter subdiretórios e arquivos  
- Fornece métodos de navegação e busca  

### FileNode
- Herda de FileSystemNode  
- Representa arquivos individuais  
- Suporta gerenciamento de conteúdo através de `FileContent`  

### FileContent
- Gerencia o conteúdo dos arquivos com diferentes estratégias de armazenamento  
- Valida a consistência do armazenamento  
- Calcula automaticamente checksums e tamanhos de arquivos  

## Estratégias de Armazenamento

### BlobStrategy
- Armazena o conteúdo diretamente no banco de dados  
- Ideal para arquivos pequenos  
- Disponibilidade imediata  

### S3Strategy
- Armazena o conteúdo no Amazon S3  
- Ideal para arquivos grandes e escalabilidade  
- Atualmente retorna `nil` (implementação placeholder)  

### DiskStrategy
- Armazena o conteúdo no sistema de arquivos local  
- Boa opção para arquivos de tamanho médio  
- Acesso direto ao sistema de arquivos  

## Objetos de Serviço

### FileCreationService
- Responsável pela criação de arquivos com diferentes tipos de armazenamento  
- Encapsula a lógica de negócios da criação de arquivos  
- Suporta múltiplas opções de armazenamento  

## Exemplos de Uso

```ruby
# Criar um diretório raiz
root = Directory.create!(name: "root")

# Criar subdiretórios
documents = root.create_subdirectory("documents")
images = root.create_subdirectory("images")

# Criar arquivos com diferentes estratégias de armazenamento
text_file = documents.create_file("readme.txt", content: "Hello World")
s3_file = documents.create_file("large.pdf", storage_type: 's3', s3_key: "files/large.pdf")
disk_file = images.create_file("photo.jpg", storage_type: 'disk', file_path: "/tmp/photo.jpg")

# Navegar no sistema de arquivos
file = root.find_by_path("documents/readme.txt")
content = file.content

# Listar conteúdo de diretórios
files = documents.list_contents
file_count = documents.files_count
```