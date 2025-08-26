SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: crawl_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crawl_runs (
    id bigint NOT NULL,
    source character varying NOT NULL,
    topic character varying NOT NULL,
    year integer NOT NULL,
    current_page integer DEFAULT 0 NOT NULL,
    total_pages integer,
    status character varying DEFAULT 'running'::character varying NOT NULL,
    last_error text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: crawl_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crawl_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crawl_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crawl_runs_id_seq OWNED BY public.crawl_runs.id;


--
-- Name: event_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_locations (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    location_id bigint NOT NULL,
    role character varying DEFAULT 'venue'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: event_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.event_locations_id_seq OWNED BY public.event_locations.id;


--
-- Name: event_media; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_media (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    media_asset_id bigint NOT NULL,
    role character varying DEFAULT 'gallery'::character varying NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: event_media_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_media_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_media_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.event_media_id_seq OWNED BY public.event_media.id;


--
-- Name: event_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_tags (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    tag_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: event_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.event_tags_id_seq OWNED BY public.event_tags.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id bigint NOT NULL,
    title character varying NOT NULL,
    description text,
    event_date date,
    event_type integer DEFAULT 0 NOT NULL,
    submitted_by_user_id bigint,
    visibility character varying DEFAULT 'public'::character varying NOT NULL,
    cover_image_url text,
    external_id character varying,
    external_source character varying,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    popularity_score double precision,
    impact_score double precision,
    confidence double precision,
    source_url text,
    event_year integer,
    CONSTRAINT events_event_type_check CHECK (((event_type >= 0) AND (event_type <= 20))),
    CONSTRAINT events_visibility_check CHECK (((visibility)::text = ANY ((ARRAY['public'::character varying, 'friends'::character varying, 'private'::character varying])::text[])))
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: ingests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ingests (
    id bigint NOT NULL,
    source character varying NOT NULL,
    external_id character varying,
    topic character varying,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    error_message text,
    event_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ingests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ingests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ingests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ingests_id_seq OWNED BY public.ingests.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations (
    id bigint NOT NULL,
    name character varying NOT NULL,
    canonical_name character varying NOT NULL,
    location_type character varying NOT NULL,
    iso_code character varying,
    aliases character varying[] DEFAULT '{}'::character varying[],
    parent_id bigint,
    coordinates public.geography(Point,4326) NOT NULL,
    external_id character varying,
    source character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- Name: media_assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_assets (
    id bigint NOT NULL,
    provider character varying NOT NULL,
    external_id character varying,
    media_type character varying NOT NULL,
    subtype character varying,
    url character varying NOT NULL,
    preview_url character varying,
    mime character varying,
    width integer,
    height integer,
    aspect_ratio double precision,
    language character varying,
    vote_count integer,
    vote_average double precision,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: media_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.media_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.media_assets_id_seq OWNED BY public.media_assets.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    name character varying NOT NULL,
    tag_type character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying,
    name character varying,
    password_digest character varying,
    birth_location character varying,
    current_location character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    google_uid character varying,
    email_verified boolean,
    avatar_url character varying,
    locale character varying,
    birthday date,
    gender character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: crawl_runs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_runs ALTER COLUMN id SET DEFAULT nextval('public.crawl_runs_id_seq'::regclass);


--
-- Name: event_locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_locations ALTER COLUMN id SET DEFAULT nextval('public.event_locations_id_seq'::regclass);


--
-- Name: event_media id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_media ALTER COLUMN id SET DEFAULT nextval('public.event_media_id_seq'::regclass);


--
-- Name: event_tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_tags ALTER COLUMN id SET DEFAULT nextval('public.event_tags_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: ingests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingests ALTER COLUMN id SET DEFAULT nextval('public.ingests_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- Name: media_assets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_assets ALTER COLUMN id SET DEFAULT nextval('public.media_assets_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: crawl_runs crawl_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_runs
    ADD CONSTRAINT crawl_runs_pkey PRIMARY KEY (id);


--
-- Name: event_locations event_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_locations
    ADD CONSTRAINT event_locations_pkey PRIMARY KEY (id);


--
-- Name: event_media event_media_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_media
    ADD CONSTRAINT event_media_pkey PRIMARY KEY (id);


--
-- Name: event_tags event_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_tags
    ADD CONSTRAINT event_tags_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: ingests ingests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingests
    ADD CONSTRAINT ingests_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: media_assets media_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_assets
    ADD CONSTRAINT media_assets_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_event_locations_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_event_locations_unique ON public.event_locations USING btree (event_id, location_id, role);


--
-- Name: idx_events_metadata_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_events_metadata_gin ON public.events USING gin (metadata);


--
-- Name: idx_events_title_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_events_title_trgm ON public.events USING gin (lower((title)::text) public.gin_trgm_ops);


--
-- Name: idx_events_unique_natural_partial; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_events_unique_natural_partial ON public.events USING btree (title, event_date, event_type) WHERE (external_source IS NULL);


--
-- Name: idx_ingests_source_external; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ingests_source_external ON public.ingests USING btree (source, external_id);


--
-- Name: idx_ingests_source_external_topic; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_ingests_source_external_topic ON public.ingests USING btree (source, external_id, topic);


--
-- Name: idx_ingests_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_ingests_unique ON public.ingests USING btree (source, external_id, topic);


--
-- Name: idx_media_provider_external; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_media_provider_external ON public.media_assets USING btree (provider, external_id, subtype);


--
-- Name: index_crawl_runs_on_source_and_topic_and_year; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_crawl_runs_on_source_and_topic_and_year ON public.crawl_runs USING btree (source, topic, year);


--
-- Name: index_event_locations_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_locations_on_event_id ON public.event_locations USING btree (event_id);


--
-- Name: index_event_locations_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_locations_on_location_id ON public.event_locations USING btree (location_id);


--
-- Name: index_event_media_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_media_on_event_id ON public.event_media USING btree (event_id);


--
-- Name: index_event_media_on_event_id_and_media_asset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_event_media_on_event_id_and_media_asset_id ON public.event_media USING btree (event_id, media_asset_id);


--
-- Name: index_event_media_on_event_id_and_role_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_media_on_event_id_and_role_and_position ON public.event_media USING btree (event_id, role, "position");


--
-- Name: index_event_media_on_media_asset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_media_on_media_asset_id ON public.event_media USING btree (media_asset_id);


--
-- Name: index_event_tags_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_tags_on_event_id ON public.event_tags USING btree (event_id);


--
-- Name: index_event_tags_on_event_id_and_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_event_tags_on_event_id_and_tag_id ON public.event_tags USING btree (event_id, tag_id);


--
-- Name: index_event_tags_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_tags_on_tag_id ON public.event_tags USING btree (tag_id);


--
-- Name: index_events_on_event_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_event_date ON public.events USING btree (event_date);


--
-- Name: index_events_on_event_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_event_year ON public.events USING btree (event_year);


--
-- Name: index_events_on_submitted_by_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_submitted_by_user_id ON public.events USING btree (submitted_by_user_id);


--
-- Name: index_ingests_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ingests_on_event_id ON public.ingests USING btree (event_id);


--
-- Name: index_ingests_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ingests_on_status ON public.ingests USING btree (status);


--
-- Name: index_ingests_on_topic; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ingests_on_topic ON public.ingests USING btree (topic);


--
-- Name: index_locations_on_aliases; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_aliases ON public.locations USING gin (aliases);


--
-- Name: index_locations_on_canonical_name_and_location_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_locations_on_canonical_name_and_location_type ON public.locations USING btree (canonical_name, location_type);


--
-- Name: index_locations_on_coordinates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_coordinates ON public.locations USING gist (coordinates);


--
-- Name: index_locations_on_iso_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_iso_code ON public.locations USING btree (iso_code);


--
-- Name: index_locations_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_parent_id ON public.locations USING btree (parent_id);


--
-- Name: index_tags_on_name_and_tag_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_name_and_tag_type ON public.tags USING btree (name, tag_type);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_google_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_google_uid ON public.users USING btree (google_uid);


--
-- Name: event_media fk_rails_24589e3112; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_media
    ADD CONSTRAINT fk_rails_24589e3112 FOREIGN KEY (event_id) REFERENCES public.events(id);


--
-- Name: event_tags fk_rails_2692903801; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_tags
    ADD CONSTRAINT fk_rails_2692903801 FOREIGN KEY (event_id) REFERENCES public.events(id);


--
-- Name: locations fk_rails_3bdd88d193; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT fk_rails_3bdd88d193 FOREIGN KEY (parent_id) REFERENCES public.locations(id);


--
-- Name: ingests fk_rails_5e529921ca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingests
    ADD CONSTRAINT fk_rails_5e529921ca FOREIGN KEY (event_id) REFERENCES public.events(id);


--
-- Name: event_media fk_rails_6bab3503d6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_media
    ADD CONSTRAINT fk_rails_6bab3503d6 FOREIGN KEY (media_asset_id) REFERENCES public.media_assets(id);


--
-- Name: event_locations fk_rails_7c5d68f3b5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_locations
    ADD CONSTRAINT fk_rails_7c5d68f3b5 FOREIGN KEY (event_id) REFERENCES public.events(id);


--
-- Name: event_tags fk_rails_a640508117; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_tags
    ADD CONSTRAINT fk_rails_a640508117 FOREIGN KEY (tag_id) REFERENCES public.tags(id);


--
-- Name: events fk_rails_d86c092020; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT fk_rails_d86c092020 FOREIGN KEY (submitted_by_user_id) REFERENCES public.users(id);


--
-- Name: event_locations fk_rails_ffe3309346; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_locations
    ADD CONSTRAINT fk_rails_ffe3309346 FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250811'),
('20250810120000'),
('20250809150010'),
('20250809150000'),
('20250809124437'),
('20250809124357'),
('20250809124323'),
('20250809124234'),
('20250809124133'),
('20250724184249'),
('20250724170652'),
('20250724164454'),
('20250724164017'),
('20250724163038'),
('20250617165906'),
('20250604161517');

