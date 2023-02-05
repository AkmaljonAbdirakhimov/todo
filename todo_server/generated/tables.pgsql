--
-- Class Todo as table todo
--

CREATE TABLE "todo" (
  "id" serial,
  "title" text NOT NULL,
  "date" timestamp without time zone NOT NULL,
  "isDone" boolean NOT NULL
);

ALTER TABLE ONLY "todo"
  ADD CONSTRAINT todo_pkey PRIMARY KEY (id);


