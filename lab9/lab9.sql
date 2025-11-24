create database dvdrental;
\c dvdrental
-- task1
create function calculate_discount(original_price numeric, discount_percent numeric)
returns numeric as $$
    begin
        return original_price - (original_price * discount_percent/100);
    end;
$$ language plpgsql;

-- task 2
SELECT calculate_discount(100, 15); -- Should return 85
SELECT calculate_discount(250.50, 20);


create function film_stats(p_rating varchar, out total_films int, out avg_rental_rate numeric)
as $$
    begin
        select count(*), avg(avg_rental_rate)
        into total_films,avg_rental_rate
        from film
        where rating = p_rating;
    end;
$$ language plpgsql;

SELECT * FROM film_stats('PG');
SELECT * FROM film_stats('R')

-- task 3
create function get_customer_rentals(p_customer_id int) as
    $$
        begin
            return query
            select rental.rental_date, film.title, rental.return_date
            from rental
            join inventory on inventory.film_id = film.film_id
            join film on film.film_id = p_customer_id
            where rental.customer_id = p_customer_id;
        end;
    $$ language plpgsql;


SELECT * FROM get_customer_rentals(1);
SELECT * FROM get_customer_rentals(5) LIMIT 5;

-- task 4

create function search_films(p_title_pattern varchar) as
    $$
        begin
            return query
            select title, release_year, rating
            from film
            where title like '%' || p_title_pattern || '%';
        end;
    $$ language plpgsql;


create function search_films(p_title_pattern varchar) as
    $$
        begin
            return query
            select title, release_year, rating
            from film
            where title like '%' || p_title_pattern || '%';
        end;
    $$ language plpgsql;

-- ver2

create function search_films(p_title_pattern varchar, p_rating varchar) as
    $$
        begin
            return query
            select title, release_year, rating
            from film
            where title like '%' || p_title_pattern || '%'
            and rating = p_rating;
        end;
    $$ language plpgsql;


SELECT * FROM search_films('A%');
SELECT * FROM search_films('A%', 'PG');




