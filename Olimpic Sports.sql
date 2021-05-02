-- • Functions & Procedures (at least 4)
-- 1. Get all information about country by country name 
CREATE OR REPLACE PROCEDURE proc_search_country ( 
    p_country IN population.country%TYPE, 
    v_country_name OUT population.country%TYPE,
    v_country_code OUT population.code%TYPE,
    v_country_population OUT population.population%TYPE) IS
BEGIN
    SELECT country, code, population INTO v_country_name, v_country_code, v_country_population FROM population WHERE country = p_country;
    EXCEPTION
        WHEN NO_DATA_FOUND 
        THEN DBMS_OUTPUT.PUT_LINE('Country name ' || p_country || ' does not exist');
END;
DECLARE 
    v_name population.country%TYPE;
    v_code population.code%TYPE;
    v_population population.population%TYPE;
BEGIN
    proc_search_country('Kazakhstan', v_name, v_code, v_population);
    dbms_output.put_line('Country name: ' || v_name || ', code: ' || v_code || ', population: ' || v_population);
END;
select * from winter WHERE medal = 'Gold' AND year = 2010 AND sport = 'Skiing';
-- 2. All Gold athlete by year and sport type
CREATE OR REPLACE PROCEDURE proc_gold_athletes (p_year NUMBER, p_sport VARCHAR2) IS
    CURSOR cur_gold_athletes IS 
        SELECT year, city, sport, discipline, athlete, country, gender, event, medal FROM winter WHERE medal = 'Gold' AND year = p_year AND sport = p_sport;
    v_year winter.year%TYPE;
    v_city winter.city%TYPE;
    v_sport winter.sport%TYPE;
    v_discipline winter.discipline%TYPE;
    v_athlete winter.athlete%TYPE;
    v_country winter.country%TYPE;
    v_gender winter.country%TYPE;
    v_event winter.event%TYPE;
    v_medal winter.medal%TYPE;
BEGIN
    OPEN cur_gold_athletes;
        LOOP
            FETCH cur_gold_athletes INTO v_year, v_city, v_sport, v_discipline, v_athlete, v_country, v_gender, v_event, v_medal;
            EXIT WHEN cur_gold_athletes%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(' Year: ' || v_year || ', City: ' || v_city || ', Sport: ' || v_sport || ', Discipline: ' || v_discipline || ', Athlete: ' || v_athlete || ', Country: ' || v_country || ', Event: ' || v_event || ', Medal: ' || v_medal);
        END LOOP;
    CLOSE cur_gold_athletes;
END;
EXEC proc_gold_athletes(2010, 'Skiing');

-- 3. Search medals by year
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE proc_total_medal_summer (p_year IN NUMBER)
IS
    CURSOR cur_total_medal IS 
        SELECT year, medal, COUNT(medal) FROM summer WHERE year = p_year GROUP BY year, medal ORDER BY year;
    v_year summer.year%TYPE;
    v_medal summer.medal%TYPE;
    v_count NUMBER;
BEGIN
    OPEN cur_total_medal;
        LOOP
            FETCH cur_total_medal INTO v_year, v_medal, v_count;
            EXIT WHEN cur_total_medal%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Year: ' || v_year || '| Medal: ' || v_medal || ' - ' || v_count);
        END LOOP;
    CLOSE cur_total_medal;
END;
EXEC proc_total_medal_summer(1900);

-- 4. 
SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION func_medal_by_country (p_country IN VARCHAR2, p_year IN NUMBER)
RETURN VARCHAR2
IS
    CURSOR cur_summer IS
        SELECT medal, COUNT(medal) 
        FROM population , summer 
        WHERE population.code = summer.country 
        AND year = p_year 
        AND population.country = p_country 
        GROUP BY medal;
    
    CURSOR cur_winter IS
        SELECT medal, COUNT(medal) 
        FROM population , winter 
        WHERE population.code = winter.country 
        AND year = p_year 
        AND population.country = p_country 
        GROUP BY medal;    
        
    v_medal summer.medal%TYPE;
    v_count NUMBER;
    v_total VARCHAR2(128) := ' Summer' || chr(10);
BEGIN
    OPEN cur_summer;
        LOOP
            FETCH cur_summer INTO v_medal, v_count;
            EXIT WHEN cur_summer%NOTFOUND;
            v_total := v_total || ' ' || v_medal || ' ' || v_count || chr(10);
        END LOOP;
    CLOSE cur_summer;
    
    v_total := v_total || 'Winter' || chr(10);
    OPEN cur_winter;
        LOOP
            FETCH cur_winter INTO v_medal, v_count;
            EXIT WHEN cur_winter%NOTFOUND;
            v_total := CONCAT(v_total || ' ' || v_medal || ' ' || v_count, chr(10));
        END LOOP;
    CLOSE cur_winter;
    RETURN v_total;
END;
DECLARE
    v_test VARCHAR2(128) := func_medal_by_country('Germany', 1992);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Germany 1992');
    DBMS_OUTPUT.PUT_LINE(v_test);
END;

-- • Collections (Arrays, Records) (at least 2)

-- • Cursors (at least 4)
-- 1. Print top 10 country by population
SET SERVEROUTPUT ON;
DECLARE
    CURSOR cur_top_populations IS
        SELECT country, code, population FROM population ORDER BY population DESC;
    v_country_name population.country%TYPE;
    v_code population.code%TYPE;
    v_population population.population%TYPE;
    v_count NUMBER := 0;
BEGIN
    OPEN cur_top_populations;
    LOOP
        FETCH cur_top_populations INTO v_country_name, v_code, v_population;
        EXIT WHEN v_count = 10;
        DBMS_OUTPUT.PUT_LINE('Country name: ' || v_country_name || ', code: ' || v_code || ', population: ' || v_population);
        v_count := v_count + 1;
    END LOOP;
    CLOSE cur_top_populations;
END;

-- 2. List of men athletes, who event 4X10KM Relay
SET SERVEROUTPUT ON;
DECLARE
    CURSOR cur_list_2010_vancouver IS
        SELECT athlete, sport, country, medal FROM winter WHERE year = 2010 AND gender = 'Men' AND event = '4X10KM Relay' ORDER BY medal;
    v_athlete winter.athlete%TYPE;
    v_sport winter.sport%TYPE;
    v_country winter.country%TYPE;
    v_medal winter.medal%TYPE;
BEGIN
    OPEN cur_list_2010_vancouver;
    LOOP
        FETCH cur_list_2010_vancouver INTO v_athlete, v_sport, v_country, v_medal;
        EXIT WHEN cur_list_2010_vancouver%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Athlete: ' || v_athlete || ', country: ' || v_country || ', sport: ' || v_sport || ', medal: ' || v_medal);     
    END LOOP;
    CLOSE cur_list_2010_vancouver;
END;

-- 3. List of all athletes participating in different years
SET SERVEROUTPUT ON;
DECLARE
    CURSOR cur_list_sports_winter IS
        SELECT year, sport, COUNT(sport) FROM winter GROUP BY sport, year ORDER BY year;
    v_year winter.year%TYPE;
    v_sport winter.sport%TYPE;
    v_count NUMBER;
BEGIN
    OPEN cur_list_sports_winter;
    LOOP
        FETCH cur_list_sports_winter INTO v_year, v_sport, v_count;
        EXIT WHEN cur_list_sports_winter%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Year: ' || v_year || ', sport: ' || v_sport || ', sum athlete: ' || v_count);     
    END LOOP;
    CLOSE cur_list_sports_winter;
END;
-- 4. List of all countries with the number of athletes in different years
SET SERVEROUTPUT ON;
DECLARE
    CURSOR cur_list_country_winter IS
        SELECT year, country, COUNT(country) FROM winter GROUP BY country, year ORDER BY year;
    v_year winter.year%TYPE;
    v_country winter.country%TYPE;
    v_count NUMBER;
BEGIN
    OPEN cur_list_country_winter;
    LOOP
        FETCH cur_list_country_winter INTO v_year, v_country, v_count;
        EXIT WHEN cur_list_country_winter%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Year: ' || v_year || ', country: ' || v_country || ', sum athlete: ' || v_count);     
    END LOOP;
    CLOSE cur_list_country_winter;
END;

-- • Packages (at least 4) [+/- 2 is fine]
-- 1. Package for population, countries
CREATE OR REPLACE PACKAGE pack_population AS
    PROCEDURE proc_search_country(p_country IN population.country%TYPE, 
                                  v_country_name OUT population.country%TYPE,
                                  v_country_code OUT population.code%TYPE,
                                  v_country_population OUT population.population%TYPE);                                    
END pack_population;

-- 2. Package for olimpic games
CREATE OR REPLACE PACKAGE pack_olimpic AS
    PROCEDURE proc_gold_athletes (p_year NUMBER, p_sport VARCHAR2);
    
    PROCEDURE proc_total_medal_summer (p_year IN NUMBER);
    
    FUNCTION func_medal_by_country (p_country IN VARCHAR2, p_year IN NUMBER) RETURN VARCHAR2;
END pack_olimpic;

-- • Triggers (at least 3)
-- 1. INSERT trigger for population table
CREATE TABLE operation (
    id NUMBER,
    operation_date DATE,
    old_country VARCHAR2(30),
    new_country VARCHAR2(30),
    old_code VARCHAR2(3),
    new_code VARCHAR2(3),
    old_population NUMBER(20, 0),
    new_population NUMBER(20, 0),
    old_gdp_per_capita NUMBER(20, 10),
    new_gdp_per_capita NUMBER(20, 10),
    action VARCHAR2(10)
);
CREATE OR REPLACE TRIGGER trigg_log_insert
AFTER INSERT 
    ON population
    FOR EACH ROW
DECLARE
    v_id operation.id%TYPE;
BEGIN
    SELECT MAX(id) INTO v_id FROM operation;
    INSERT INTO operation VALUES ( v_id + 1, SYSDATE, NULL, :NEW.country, NULL, :NEW.code , NULL , :NEW.population, NULL, :NEW.gdp_per_capita, 'INSERT');
END;
select * from population;
insert into population VALUES ('test', 'tst', 10000, 1000.00);
select * from operation;

-- 2. DELETE trigger for population table
CREATE OR REPLACE TRIGGER trigg_log_delete 
AFTER DELETE 
    ON population
    FOR EACH ROW
DECLARE
    v_id operation.id%TYPE;
BEGIN
    SELECT MAX(id) INTO v_id FROM operation;
    INSERT INTO operation VALUES ( v_id + 1, SYSDATE, :OLD.country, NULL, :OLD.code , NULL , :OLD.population, NULL, :OLD.gdp_per_capita, NULL, 'DELETE');
END;
select * from population;
DELETE FROM population WHERE country = 'test';
select * from operation;

-- 3. UPDATE trigger for population
CREATE OR REPLACE TRIGGER trigg_log_update
AFTER UPDATE
    ON population
    FOR EACH ROW
DECLARE
    v_id operation.id%TYPE;
BEGIN
    SELECT MAX(id) INTO v_id FROM operation;
    INSERT INTO operation VALUES ( v_id + 1, SYSDATE, :OLD.country, :NEW.country, :OLD.code , :NEW.code, :OLD.population, :NEW.population, :OLD.gdp_per_capita, :NEW.gdp_per_capita, 'UPDATE');
END;
select * from population;
UPDATE population SET country = 'aaaa' WHERE country = 'test';
select * from operation;

-- • Usage of Dynamic SQL (at least 3)


