DELIMITER //
 DROP PROCEDURE IF EXISTS  update_global_rank //
 CREATE PROCEDURE update_global_rank()
 BEGIN
   DECLARE id_no INT(11);
   DECLARE rowNumber INT DEFAULT 1;
   DECLARE name VARCHAR(255);
   
   -- this flag will be set to true when cursor reaches end of table
   DECLARE exit_loop BOOLEAN;         
   
   -- Declare the cursor
   DECLARE reward_cursor CURSOR FOR 
   SELECT id, @rownum := @rownum + 1 AS position 
        FROM rewardpoints JOIN (SELECT @rownum := 0) r ORDER BY points desc, modifiedTime asc;
   
   -- set exit_loop flag to true if there are no more rows
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET exit_loop = TRUE;
   
   -- open the cursor
   OPEN reward_cursor;
   
   -- start looping
   reward_loop: LOOP
   
     -- read the name from next row into the variables 
     FETCH  reward_cursor INTO id_no, rowNumber;
	 update rewardpoints set previousRank=rowNumber, rankUpdateTime=now() where id=id_no;
     
     -- check if the exit_loop flag has been set by mysql, 
     -- close the cursor and exit the loop if it has.
     IF exit_loop THEN
         CLOSE reward_cursor;
         LEAVE reward_loop;
     END IF;
     
	 
   END LOOP reward_loop;
 END //
 DELIMITER ;