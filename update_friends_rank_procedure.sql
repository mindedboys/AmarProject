DELIMITER //
 DROP PROCEDURE IF EXISTS  update_friends_rank //
 CREATE PROCEDURE update_friends_rank()
 BEGIN
   DECLARE user_userid INT(11);
   DECLARE user_friend_id INT(11);
   DECLARE friend_user INT(11);
   DECLARE rowNumber INT DEFAULT 1;
   DECLARE name VARCHAR(255);

   -- this flag will be set to true when cursor reaches end of table
   DECLARE exit_loop BOOLEAN;
   -- Declare the cursor
   DECLARE friends_cursor CURSOR FOR
   SELECT distinct user FROM userfriends ;
   -- set exit_loop flag to true if there are no more rows
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET exit_loop = TRUE;
   -- open the cursor
   OPEN friends_cursor;
   -- start looping
   friends_loop: LOOP
     -- read the name from next row into the variables
     FETCH friends_cursor INTO user_userid;
		BLOCK2: BEGIN
         -- this flag will be set to true when cursor reaches end of table
         DECLARE exit_user_friend_loop BOOLEAN;
         -- Declare the cursor
         DECLARE user_friends_cursor CURSOR FOR
         SELECT uf.id, uf.friendUser, @rownum := @rownum + 1 AS position
            FROM  rewardpoints rp, userfriends uf JOIN (SELECT @rownum := 0) r
            where  uf.friendUser=rp.user and uf.user=user_userid
            ORDER BY rp.points desc, rp.modifiedTime asc;
             -- set exit_loop flag to true if there are no more rows
             DECLARE CONTINUE HANDLER FOR NOT FOUND SET exit_user_friend_loop = TRUE;
             -- open the cursor
             OPEN user_friends_cursor;
             -- start looping
             user_friends_loop: LOOP
               -- read the name from next row into the variables
               FETCH  user_friends_cursor INTO user_friend_id,friend_user, rowNumber;
              update userfriends set rewardPointRank=rowNumber, rankUpdatedTime=now() where id=user_friend_id;
               -- check if the exit_loop flag has been set by mysql,
               -- close the cursor and exit the loop if it has.
               IF exit_user_friend_loop THEN
                   CLOSE user_friends_cursor;
                   LEAVE user_friends_loop;
               END IF;
             END LOOP user_friends_loop;
			END BLOCK2;
     -- check if the exit_loop flag has been set by mysql,
     -- close the cursor and exit the loop if it has.
     IF exit_loop THEN
         CLOSE friends_cursor;
         LEAVE friends_loop;
     END IF;
   END LOOP friends_loop;
 END //
 DELIMITER ;
