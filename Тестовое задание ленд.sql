-- создадим временную табличку, с расчетом количества домашек, потом присоеденим ее к основному запрос
WITH t_homework AS
(
    SELECT user_id, COUNT(*) AS cnt_homework
    FROM homework_done
    GROUP BY user_id
)

SELECT
    uc.course_id,
    c.name AS course_name,
    s.name AS subjects_name,
    s.project AS subjects_type,
    ct.name as course_type_name,
    c.starts_at AS course_data_start,
    uc.user_id,
    u.last_name,
    ci.name AS city_name,
    uc.active,
    CAST(uc.created_at AS DATE) AS date_join_cours, -- используем дату, в которую появилась запись об ученике + его курсе, как дату открытия курса ученику
    FLOOR(uc.available_lessons / c.lessons_in_month) AS cnt_open_month, -- С помощью деления количество открытых уроков на число уроков в месяц получаем количество месяцев,
                                                                        -- которые ученики оплатили,
                                                                        -- floor() используем для округления в меньшую сторону, чтобы получить только полные месяцы
    t.cnt_homework
FROM
    course_users uc
LEFT JOIN
    courses c ON uc.course_id = c.id
LEFT JOIN
    subjects s ON c.subject_id = s.id
JOIN
    users u ON u.id = uc.user_id -- в таблице users есть ученики, которые не присоединилсь к курсу, они нас не интересуют, поэтому используем обычный join
LEFT JOIN
    cities ci ON ci.id = u.city_id
LEFT JOIN
    t_homework t ON uc.user_id = t.user_id
LEFT JOIN
    course_types ct ON ct.id = c.course_type_id
 WHERE s.project in ('ЕГЭ', 'ОГЭ') and ct.name in ('Годовой', 'Годовой 2.0')