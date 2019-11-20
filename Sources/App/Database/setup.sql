drop table if exists access_tokens CASCADE;
drop table if exists refresh_tokens CASCADE;
drop table if exists users CASCADE;
drop table if exists words CASCADE;
drop table if exists translations CASCADE;
drop table if exists sentences CASCADE;
drop table if exists words_sentences CASCADE;
drop table if exists chapters CASCADE;
drop table if exists books CASCADE;
drop table if exists authors CASCADE;
drop table if exists books_authors CASCADE;
drop table if exists languages CASCADE;
drop table if exists words_translations CASCADE;
drop table if exists translations CASCADE;
drop table if exists sentence_translations CASCADE;

create table users (
    id         serial primary key,
    name       varchar(255),
    email      varchar(255) not null unique,
    password   varchar(255) not null,
    created_at timestamp not null
);

create table access_tokens (
    id         serial primary key,
    value      varchar(64) not null unique,
    user_id    integer references users(id),
    created_at timestamp not null,
    expired_in timestamp not null
);

create table refresh_tokens (
    id         serial primary key,
    value      varchar(64) not null unique,
    user_id    integer references users(id),
    created_at timestamp not null,
    expired_in timestamp not null
);

create table words (
    id    serial primary key,
    value varchar(255)
);

create table languages (
    id    serial primary key,
    value varchar(64)
);

create table words_translations (
    id                  serial primary key,
    word_id             integer references words(id),
    language_id         integer references languages(id),
    word_translation_id integer references words_translations(id)
);

create table translations (
    id    serial primary key,
    value varchar(255)
);

create table book_categories (
    id    serial primary key,
    value varchar(255)
);

create table books (
    id              serial primary key,
    name            varchar (255),
    number_of_pages integer,
    year            integer,
    url             varchar (255),
    format          varchar (64),
    book_categories id
);

create table chapters (
    id          serial primary key,
    title       varchar (255),
    index       integer,
    index_value varchar (255),
    book_id     integer references books(id)
);

create table sentences (
    id         serial primary key,
    value      text,
    index      integer,
    chapter_id integer references chapters(id)
);

create table words_sentences (
    id          serial primary key,
    word_id     integer references words(id),
    sentence_id integer references sentences(id),
    index       integer
);

create table sentence_translations (
    id          serial primary key,
    sentence_id integer references sentences(id),
    language_id integer references languages(id),
    value       varchar(255)
);

create table authors (
    id           serial primary key,
    name varchar (255)
);

create table books_authors (
    id        serial primary key,
    book_id   integer references books(id),
    author_id integer references authors(id)
);

