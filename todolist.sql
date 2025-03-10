PGDMP  *                    }            Todolist    16.4    16.4 G    D           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            E           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            F           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            G           1262    33467    Todolist    DATABASE     �   CREATE DATABASE "Todolist" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Kazakhstan.1251';
    DROP DATABASE "Todolist";
                postgres    false                        2615    33468    todolist    SCHEMA        CREATE SCHEMA todolist;
    DROP SCHEMA todolist;
                postgres    false            �            1255    33595 
   add_task()    FUNCTION     �  CREATE FUNCTION todolist.add_task() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    IF (COALESCE(NEW.category_id, 0) > 0 AND NEW.completed = 1) THEN
        UPDATE todolist.category
        SET completed_count = (COALESCE(completed_count, 0) + 1)
        WHERE id = NEW.category_id
          AND user_id = NEW.user_id;
    END IF;
    IF (COALESCE(NEW.category_id, 0) > 0 AND NEW.completed = 0) THEN
        UPDATE todolist.category
        SET uncompleted_count = (COALESCE(uncompleted_count, 0) + 1)
        WHERE id = NEW.category_id
          AND user_id = NEW.user_id;
    END IF;
	

	--общая статистика
	if coalesce(new.completed,0)=1 then
		update todolist.stat 
		set completed_total = (coalesce(completed_total,0)+1)
		where user_id=new.user_id;
	else 
		update todolist.stat 
		set uncompleted_total = (coalesce(uncompleted_total,0)+1)
		where user_id=new.user_id; 

    END IF;
    RETURN NEW;
END;$$;
 #   DROP FUNCTION todolist.add_task();
       todolist          postgres    false    6            �            1255    33600    delete_task()    FUNCTION     X  CREATE FUNCTION todolist.delete_task() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    -- Если category не null и completed = 1
    IF COALESCE(OLD.category_id, 0) > 0 AND COALESCE(OLD.completed, 0) = 1 THEN
        UPDATE todolist.category
        SET completed_count = COALESCE(completed_count, 0) - 1
        WHERE id = OLD.category_id
          AND user_id = OLD.user_id;
    END IF;

    -- Если category не null и completed = 0
    IF COALESCE(OLD.category_id, 0) > 0 AND COALESCE(OLD.completed, 0) = 0 THEN
        UPDATE todolist.category
        SET uncompleted_count = COALESCE(uncompleted_count, 0) - 1
        WHERE id = OLD.category_id
          AND user_id = OLD.user_id;
    END IF;

    -- Общая статистика
    IF COALESCE(OLD.completed, 0) = 1 THEN
        UPDATE todolist.stat
        SET completed_total = COALESCE(completed_total, 0) - 1
        WHERE user_id = OLD.user_id;
    ELSE
        UPDATE todolist.stat
        SET uncompleted_total = COALESCE(uncompleted_total, 0) - 1
        WHERE user_id = OLD.user_id;
    END IF;

    RETURN OLD;
END;
$$;
 &   DROP FUNCTION todolist.delete_task();
       todolist          postgres    false    6            �            1255    33614    new_user_data()    FUNCTION     �  CREATE FUNCTION todolist.new_user_data() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
 
 /* для хранения id вставленных тестовых данных - чтобы их можно было использовать при создании тестовых задач*/
 priorId1 INTEGER; 
 priorId2 INTEGER;
 priorId3 INTEGER;
 
 catId1 INTEGER;
 catId2 INTEGER;
 catId3 INTEGER;
 
 /* тестовые даты */
 date1 Date = NOW() + INTERVAL '1 day';
 date2 Date = NOW();
 date3 Date = NOW() + INTERVAL '6 day';

 /* ID роли из таблицы role_data */
 roleId INTEGER = 2;

BEGIN

  /* при вставке нового пользователя - создаем строку активности */
    insert into todolist.activity (uuid, activated, user_id) values (gen_random_uuid (), 0, new.id);
    
 /* при вставке нового пользователя - создаем строку для хранения общей статистики - это не тестовые данные, а обязательные (иначе общая статистика не будет работать)*/
    insert into todolist.stat (completed_total, uncompleted_total, user_id) values (0,0, new.id);
    
 /* добавляем начальные тестовые категории для нового созданного пользователя */
    insert into todolist.category (title, completed_count, uncompleted_count, user_id) values ('Семья',0 ,0 ,new.id) RETURNING id into catId1; /* сохранить id вставленной записи в переменную */
    insert into todolist.category (title, completed_count, uncompleted_count, user_id) values ('Работа',0 ,0 ,new.id) RETURNING id into catId2;
 insert into todolist.category (title, completed_count, uncompleted_count, user_id) values ('Отдых',0 ,0 ,new.id) RETURNING id into catId3;
 insert into todolist.category (title, completed_count, uncompleted_count, user_id) values ('Путешествия',0 ,0 ,new.id);
    insert into todolist.category (title, completed_count, uncompleted_count, user_id) values ('Спорт',0 ,0 ,new.id);
    insert into todolist.category (title, completed_count, uncompleted_count, user_id) values ('Здоровье',0 ,0 ,new.id);



 /* добавляем начальные тестовые приоритеты для созданного пользователя */
    insert into todolist.priority (title, color, user_id) values ('Низкий', '#caffdd', new.id) RETURNING id into priorId1;
    insert into todolist.priority (title, color, user_id) values ('Средний', '#b488e3', new.id) RETURNING id into priorId2;
    insert into todolist.priority (title, color, user_id) values ('Высокий', '#f05f5f', new.id) RETURNING id into priorId3;



     
 /* добавляем начальные тестовые задачи для созданного пользователя */
    insert into todolist.task (title, completed, user_id, priority_id, category_id, task_date) values ('Позвонить родителям', 0, new.id, priorId1, catId1, date1);
    insert into todolist.task (title, completed, user_id, priority_id, category_id, task_date) values ('Посмотреть мультики', 1,  new.id, priorId1, catId3, date2);
    insert into todolist.task (title, completed, user_id, priority_id, category_id) values ('Пройти курсы по Java', 0, new.id, priorId3, catId2);
    insert into todolist.task (title, completed, user_id, priority_id) values ('Сделать зеленый коктейль', 1, new.id, priorId3);
    insert into todolist.task (title, completed, user_id, priority_id, task_date) values ('Купить буханку хлеба', 0, new.id, priorId2, date3);

 /* по-умолчанию добавляем новому пользователю роль USER */
    insert into todolist.user_role (user_id, role_id) values (new.id, roleId);

 
 RETURN NEW;
END;$$;
 (   DROP FUNCTION todolist.new_user_data();
       todolist          postgres    false    6            �            1255    33598    update_task()    FUNCTION     �  CREATE FUNCTION todolist.update_task() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    -- Изменение статуса completed с 0 на 1, если категория не изменилась
    IF (COALESCE(OLD.completed, 0) = 0 
        AND NEW.completed = 1 
        AND COALESCE(OLD.category_id, 0) = COALESCE(NEW.category_id, 0)) THEN

        UPDATE todolist.category
        SET uncompleted_count = (COALESCE(uncompleted_count, 0) - 1),
            completed_count   =(COALESCE(completed_count, 0) + 1)
        WHERE id = OLD.category_id
          AND user_id = OLD.user_id;
		--общая статистика
		update todolist.stat 
		set uncompleted_total=(coalesce(uncompleted_total,0)-1), 
			completed_total=(coalesce(completed_total,0)+1)
		where user_id = old.user_id;
    END IF;
	-- Изменение статуса completed с 1 на 0, если категория не изменилась
    IF (COALESCE(OLD.completed, 1) = 1 
        AND NEW.completed = 0 
        AND COALESCE(OLD.category_id, 0) = COALESCE(NEW.category_id, 0)) THEN

        UPDATE todolist.category
        SET uncompleted_count = (COALESCE(uncompleted_count, 0) + 1),
            completed_count   = (COALESCE(completed_count, 0) - 1)
        WHERE id = OLD.category_id
          AND user_id = OLD.user_id;
		--общая статистика
		update todolist.stat 
		set uncompleted_total=(coalesce(uncompleted_total,0)+1), 
			completed_total=(coalesce(completed_total,0)-1)
		where user_id = old.user_id;
    END IF;

	-- Изменили категорию, не изменили completed=1
    IF (COALESCE(OLD.category_id, 0) <> COALESCE(NEW.category_id,0)
		AND COALESCE(OLD.completed, 1)=1 
		AND NEW.completed=1
		) THEN

        UPDATE todolist.category
        SET completed_count   = (COALESCE(completed_count, 0) - 1)
        WHERE id = OLD.category_id
          AND user_id = OLD.user_id;
		  
		UPDATE todolist.category
        SET completed_count   = (COALESCE(completed_count, 0) + 1)
        WHERE id = new.category_id
          AND user_id = old.user_id;
    END IF;

	-- Изменили категорию, не изменили completed=0
    IF (COALESCE(OLD.category_id, 0) <> COALESCE(NEW.category_id,0)
		AND COALESCE(OLD.completed, 0)=0 
		AND NEW.completed=0
		) THEN

        UPDATE todolist.category
        SET uncompleted_count   = (COALESCE(uncompleted_count, 0) - 1)
        WHERE id = OLD.category_id
          AND user_id = OLD.user_id;
		  
		UPDATE todolist.category
        SET uncompleted_count   = (COALESCE(uncompleted_count, 0) + 1)
        WHERE id = new.category_id
          AND user_id = old.user_id;
    END IF;

	-- Изменили категорию,  изменили completed 0->1
    IF (COALESCE(OLD.category_id, 0) <> COALESCE(NEW.category_id,0)
		AND COALESCE(OLD.completed, 0)=0 
		AND NEW.completed=1
		) THEN

        UPDATE todolist.category
        SET uncompleted_count   = (COALESCE(uncompleted_count, 0) - 1)
        WHERE id = OLD.category_id
          AND user_id = OLD.user_id;
		  
		UPDATE todolist.category
        SET completed_count   = (COALESCE(completed_count, 0) + 1)
        WHERE id = new.category_id
          AND user_id = old.user_id;
		--общая статистика
		update todolist.stat 
		set uncompleted_total=(coalesce(uncompleted_total,0)-1), 
			completed_total=(coalesce(completed_total,0)+1)
		where user_id = old.user_id;
    END IF;

	-- Изменили категорию,  изменили completed 1->0
    IF (COALESCE(OLD.category_id, 0) <> COALESCE(NEW.category_id,0)
		AND COALESCE(OLD.completed, 1)=1 
		AND NEW.completed=0
		) THEN

        UPDATE todolist.category
        SET completed_count   = (COALESCE(completed_count, 0) - 1)
        WHERE id = OLD.category_id
          AND user_id = OLD.user_id;
		  
		UPDATE todolist.category
        SET uncompleted_count   = (COALESCE(uncompleted_count, 0) + 1)
        WHERE id = new.category_id
          AND user_id = old.user_id;
		--общая статистика
		update todolist.stat 
		set uncompleted_total=(coalesce(uncompleted_total,0)+1), 
			completed_total=(coalesce(completed_total,0)-1)
		where user_id = old.user_id;
    END IF;
	RETURN NEW;
END;
$$;
 &   DROP FUNCTION todolist.update_task();
       todolist          postgres    false    6            �            1259    33478    category    TABLE     �   CREATE TABLE todolist.category (
    title text NOT NULL,
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    completed_count bigint,
    uncompleted_count bigint
);
    DROP TABLE todolist.category;
       todolist         heap    postgres    false    6            �            1259    33469    task    TABLE     �   CREATE TABLE todolist.task (
    title text NOT NULL,
    completed smallint NOT NULL,
    task_date timestamp without time zone,
    id bigint NOT NULL,
    category_id bigint,
    priority_id bigint,
    user_id bigint NOT NULL
);
    DROP TABLE todolist.task;
       todolist         heap    postgres    false    6            �            1259    33472 	   user_data    TABLE     �   CREATE TABLE todolist.user_data (
    email text NOT NULL,
    user_password text NOT NULL,
    username text NOT NULL,
    id bigint NOT NULL
);
    DROP TABLE todolist.user_data;
       todolist         heap    postgres    false    6            �            1259    33547    Task_inner-mul-groupby    VIEW     B  CREATE VIEW todolist."Task_inner-mul-groupby" AS
 SELECT count(t.id) AS counttasks,
    u.username,
    c.title
   FROM ((todolist.task t
     JOIN todolist.user_data u ON ((t.user_id = u.id)))
     JOIN todolist.category c ON ((t.category_id = c.id)))
  GROUP BY t.category_id, u.username, c.title
  ORDER BY u.username;
 -   DROP VIEW todolist."Task_inner-mul-groupby";
       todolist          postgres    false    217    219    219    217    216    216    216    6            �            1259    33660    activity    TABLE     �   CREATE TABLE todolist.activity (
    id bigint NOT NULL,
    uuid text NOT NULL,
    activated smallint NOT NULL,
    user_id bigint NOT NULL
);
    DROP TABLE todolist.activity;
       todolist         heap    postgres    false    6            �            1259    33659    activity_id_seq    SEQUENCE     �   ALTER TABLE todolist.activity ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME todolist.activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            todolist          postgres    false    6    233            �            1259    33497    category_id_seq    SEQUENCE     �   ALTER TABLE todolist.category ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME todolist.category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            todolist          postgres    false    6    219            �            1259    33475    priority    TABLE     �   CREATE TABLE todolist.priority (
    title text NOT NULL,
    color text NOT NULL,
    id bigint NOT NULL,
    user_id bigint NOT NULL
);
    DROP TABLE todolist.priority;
       todolist         heap    postgres    false    6            �            1259    33498    priority_id_seq    SEQUENCE     �   ALTER TABLE todolist.priority ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME todolist.priority_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            todolist          postgres    false    6    218            �            1259    33562 	   role_data    TABLE     T   CREATE TABLE todolist.role_data (
    id bigint NOT NULL,
    name text NOT NULL
);
    DROP TABLE todolist.role_data;
       todolist         heap    postgres    false    6            �            1259    33561    role_data_id_seq    SEQUENCE     �   ALTER TABLE todolist.role_data ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME todolist.role_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            todolist          postgres    false    227    6            �            1259    33603    stat    TABLE     �   CREATE TABLE todolist.stat (
    id bigint NOT NULL,
    completed_total bigint,
    uncompleted_total bigint,
    user_id bigint
);
    DROP TABLE todolist.stat;
       todolist         heap    postgres    false    6            �            1259    33602    stat_id_seq    SEQUENCE     �   ALTER TABLE todolist.stat ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME todolist.stat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            todolist          postgres    false    231    6            �            1259    33499    task_id_seq    SEQUENCE     �   ALTER TABLE todolist.task ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME todolist.task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            todolist          postgres    false    6    216            �            1259    33560    test_seq    SEQUENCE     s   CREATE SEQUENCE todolist.test_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 !   DROP SEQUENCE todolist.test_seq;
       todolist          postgres    false    6            �            1259    33500    user_data_id_seq    SEQUENCE     �   ALTER TABLE todolist.user_data ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME todolist.user_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            todolist          postgres    false    217    6            �            1259    33567 	   user_role    TABLE     v   CREATE TABLE todolist.user_role (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    role_id bigint NOT NULL
);
    DROP TABLE todolist.user_role;
       todolist         heap    postgres    false    6            �            1259    33594    user_role_id_seq    SEQUENCE     �   ALTER TABLE todolist.user_role ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME todolist.user_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            todolist          postgres    false    228    6            A          0    33660    activity 
   TABLE DATA           B   COPY todolist.activity (id, uuid, activated, user_id) FROM stdin;
    todolist          postgres    false    233   �x       4          0    33478    category 
   TABLE DATA           \   COPY todolist.category (title, id, user_id, completed_count, uncompleted_count) FROM stdin;
    todolist          postgres    false    219   y       3          0    33475    priority 
   TABLE DATA           ?   COPY todolist.priority (title, color, id, user_id) FROM stdin;
    todolist          postgres    false    218   Yy       ;          0    33562 	   role_data 
   TABLE DATA           /   COPY todolist.role_data (id, name) FROM stdin;
    todolist          postgres    false    227   �y       ?          0    33603    stat 
   TABLE DATA           Q   COPY todolist.stat (id, completed_total, uncompleted_total, user_id) FROM stdin;
    todolist          postgres    false    231   �y       1          0    33469    task 
   TABLE DATA           d   COPY todolist.task (title, completed, task_date, id, category_id, priority_id, user_id) FROM stdin;
    todolist          postgres    false    216   �y       2          0    33472 	   user_data 
   TABLE DATA           I   COPY todolist.user_data (email, user_password, username, id) FROM stdin;
    todolist          postgres    false    217   �z       <          0    33567 	   user_role 
   TABLE DATA           ;   COPY todolist.user_role (id, user_id, role_id) FROM stdin;
    todolist          postgres    false    228   7{       H           0    0    activity_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('todolist.activity_id_seq', 1, false);
          todolist          postgres    false    232            I           0    0    category_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('todolist.category_id_seq', 9, true);
          todolist          postgres    false    220            J           0    0    priority_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('todolist.priority_id_seq', 2, true);
          todolist          postgres    false    221            K           0    0    role_data_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('todolist.role_data_id_seq', 2, true);
          todolist          postgres    false    226            L           0    0    stat_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('todolist.stat_id_seq', 5, true);
          todolist          postgres    false    230            M           0    0    task_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('todolist.task_id_seq', 17, true);
          todolist          postgres    false    222            N           0    0    test_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('todolist.test_seq', 4, true);
          todolist          postgres    false    225            O           0    0    user_data_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('todolist.user_data_id_seq', 4, true);
          todolist          postgres    false    223            P           0    0    user_role_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('todolist.user_role_id_seq', 6, true);
          todolist          postgres    false    229            �           2606    33666    activity activity_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY todolist.activity
    ADD CONSTRAINT activity_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY todolist.activity DROP CONSTRAINT activity_pkey;
       todolist            postgres    false    233            �           2606    33496    category category_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY todolist.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY todolist.category DROP CONSTRAINT category_pkey;
       todolist            postgres    false    219            �           2606    33492    priority priority_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY todolist.priority
    ADD CONSTRAINT priority_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY todolist.priority DROP CONSTRAINT priority_pkey;
       todolist            postgres    false    218            �           2606    33573    role_data role_data_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY todolist.role_data
    ADD CONSTRAINT role_data_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY todolist.role_data DROP CONSTRAINT role_data_pkey;
       todolist            postgres    false    227            �           2606    33607    stat stat_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY todolist.stat
    ADD CONSTRAINT stat_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY todolist.stat DROP CONSTRAINT stat_pkey;
       todolist            postgres    false    231            ~           2606    33494    task task_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY todolist.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY todolist.task DROP CONSTRAINT task_pkey;
       todolist            postgres    false    216            �           2606    33490    user_data user_data_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY todolist.user_data
    ADD CONSTRAINT user_data_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY todolist.user_data DROP CONSTRAINT user_data_pkey;
       todolist            postgres    false    217            �           2606    33571    user_role user_role_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY todolist.user_role
    ADD CONSTRAINT user_role_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY todolist.user_role DROP CONSTRAINT user_role_pkey;
       todolist            postgres    false    228            �           2606    33668    activity user_uniq 
   CONSTRAINT     R   ALTER TABLE ONLY todolist.activity
    ADD CONSTRAINT user_uniq UNIQUE (user_id);
 >   ALTER TABLE ONLY todolist.activity DROP CONSTRAINT user_uniq;
       todolist            postgres    false    233            �           1259    33674    activity_user_id_idx    INDEX     n   CREATE INDEX activity_user_id_idx ON todolist.activity USING btree (user_id) WITH (deduplicate_items='true');
 *   DROP INDEX todolist.activity_user_id_idx;
       todolist            postgres    false    233                       1259    33552 	   title_idx    INDEX     ]   CREATE INDEX title_idx ON todolist.task USING btree (title) WITH (deduplicate_items='true');
    DROP INDEX todolist.title_idx;
       todolist            postgres    false    216            �           1259    33675    user_activated_idx    INDEX     n   CREATE INDEX user_activated_idx ON todolist.activity USING btree (activated) WITH (deduplicate_items='true');
 (   DROP INDEX todolist.user_activated_idx;
       todolist            postgres    false    233            �           1259    33676    user_uuid_idx    INDEX     d   CREATE INDEX user_uuid_idx ON todolist.activity USING btree (uuid) WITH (deduplicate_items='true');
 #   DROP INDEX todolist.user_uuid_idx;
       todolist            postgres    false    233            �           2620    33596    task add_task_stat    TRIGGER     n   CREATE TRIGGER add_task_stat AFTER INSERT ON todolist.task FOR EACH ROW EXECUTE FUNCTION todolist.add_task();
 -   DROP TRIGGER add_task_stat ON todolist.task;
       todolist          postgres    false    216    245            �           2620    33601    task delete_task_stat    TRIGGER     t   CREATE TRIGGER delete_task_stat AFTER DELETE ON todolist.task FOR EACH ROW EXECUTE FUNCTION todolist.delete_task();
 0   DROP TRIGGER delete_task_stat ON todolist.task;
       todolist          postgres    false    216    247            �           2620    33677    user_data new_user_gen_data    TRIGGER     }   CREATE TRIGGER new_user_gen_data BEFORE INSERT ON todolist.user_data FOR EACH ROW EXECUTE FUNCTION todolist.new_user_data();
 6   DROP TRIGGER new_user_gen_data ON todolist.user_data;
       todolist          postgres    false    217    248            �           2620    33615    user_role new_user_trigger    TRIGGER     {   CREATE TRIGGER new_user_trigger AFTER INSERT ON todolist.user_role FOR EACH ROW EXECUTE FUNCTION todolist.new_user_data();
 5   DROP TRIGGER new_user_trigger ON todolist.user_role;
       todolist          postgres    false    248    228            �           2620    33599    task update_task_stat    TRIGGER     t   CREATE TRIGGER update_task_stat AFTER UPDATE ON todolist.task FOR EACH ROW EXECUTE FUNCTION todolist.update_task();
 0   DROP TRIGGER update_task_stat ON todolist.task;
       todolist          postgres    false    246    216            �           2606    33641    user_role User_data_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY todolist.user_role
    ADD CONSTRAINT "User_data_fkey" FOREIGN KEY (user_id) REFERENCES todolist.user_data(id) ON DELETE CASCADE NOT VALID;
 F   ALTER TABLE ONLY todolist.user_role DROP CONSTRAINT "User_data_fkey";
       todolist          postgres    false    228    217    4737            �           2606    33616    task category_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY todolist.task
    ADD CONSTRAINT category_fkey FOREIGN KEY (category_id) REFERENCES todolist.category(id) ON DELETE SET NULL NOT VALID;
 >   ALTER TABLE ONLY todolist.task DROP CONSTRAINT category_fkey;
       todolist          postgres    false    4741    219    216            �           2606    33621    task priority_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY todolist.task
    ADD CONSTRAINT priority_fkey FOREIGN KEY (priority_id) REFERENCES todolist.priority(id) ON DELETE SET NULL NOT VALID;
 >   ALTER TABLE ONLY todolist.task DROP CONSTRAINT priority_fkey;
       todolist          postgres    false    4739    218    216            �           2606    33646    user_role role_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY todolist.user_role
    ADD CONSTRAINT role_fkey FOREIGN KEY (role_id) REFERENCES todolist.role_data(id) ON DELETE RESTRICT NOT VALID;
 ?   ALTER TABLE ONLY todolist.user_role DROP CONSTRAINT role_fkey;
       todolist          postgres    false    228    227    4743            �           2606    33609    stat user_data_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY todolist.stat
    ADD CONSTRAINT user_data_fkey FOREIGN KEY (user_id) REFERENCES todolist.user_data(id) ON DELETE CASCADE NOT VALID;
 ?   ALTER TABLE ONLY todolist.stat DROP CONSTRAINT user_data_fkey;
       todolist          postgres    false    231    4737    217            �           2606    33525    priority user_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY todolist.priority
    ADD CONSTRAINT user_fkey FOREIGN KEY (user_id) REFERENCES todolist.user_data(id) NOT VALID;
 >   ALTER TABLE ONLY todolist.priority DROP CONSTRAINT user_fkey;
       todolist          postgres    false    218    217    4737            �           2606    33626    task user_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY todolist.task
    ADD CONSTRAINT user_fkey FOREIGN KEY (user_id) REFERENCES todolist.user_data(id) ON DELETE CASCADE NOT VALID;
 :   ALTER TABLE ONLY todolist.task DROP CONSTRAINT user_fkey;
       todolist          postgres    false    217    4737    216            �           2606    33636    category user_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY todolist.category
    ADD CONSTRAINT user_fkey FOREIGN KEY (user_id) REFERENCES todolist.user_data(id) ON DELETE CASCADE NOT VALID;
 >   ALTER TABLE ONLY todolist.category DROP CONSTRAINT user_fkey;
       todolist          postgres    false    219    217    4737            �           2606    33669    activity user_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY todolist.activity
    ADD CONSTRAINT user_fkey FOREIGN KEY (user_id) REFERENCES todolist.user_data(id) ON DELETE CASCADE NOT VALID;
 >   ALTER TABLE ONLY todolist.activity DROP CONSTRAINT user_fkey;
       todolist          postgres    false    4737    217    233            A      x������ � �      4   .   x�sM)MN,����4�4�4�4�rK��̩�4�4�4�4����� �H�      3   #   x���/�TNKK�4�4���Lπ��8�b���� ��U      ;      x�3�tt����2�v����� +��      ?   '   x�3�4�4�4�2��&\&@҈ӈ(��b���� S�^      1   �   x�M��
�0���S��6�<�ED�(x��tc���*���� �~��߾��Q�( I���	I�r�$0�D��=[W��cj6`i�N�ȭ���m��*�Oe�)��n�XZٟ���>x�J��3<n�ŝH�"=�E	�DI���2|�1s9_F���v��r�ǱӁ�?��Ak�9>ߥ/za���:B���?r�
!�f�T>      2   ^   x�M�K� E�q���&�h�&T�zMG��}yT�I3g�/���)2Pm=Q�M�������B�I;$���������Uݿ�"~Z�,�      <   )   x�3�4�4�2�B.SN ۘ�����PĈ+F��� f��     