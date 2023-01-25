
/*
[Question]

Below table has bank transaction data.
Please query to get the following table.

{   
    'user_id' string,
    'outgoing' integer,
    'incoming' integer,
    'total' integer
}

* user_id : Customer's id
* outgoing : Number of sent transactions
* incoming : Number of received transactions
* total : Total amount of balance
*/

-- [Table schema]
create table transactions (
	sender varchar(255),
    recipient varchar(255),
    amount int
);

insert into transactions (sender, recipient, amount)
values 
(1, 2, 600),
(1, 3, 400),
(2, 1, 200),
(3, 2, 500),
(2, 3, 300);

select * from transactions;

-- [Answer here]
-- how many times and how much a customer sent
with
sent as (
	select sender, count(sender) as 'outgoing', sum(amount) as 'total_sent'
	from transactions
	group by sender
),
-- how many times and how much a customer received
received as (
	select recipient, count(recipient) as 'incoming', sum(amount) as 'total_received'
	from transactions
	group by recipient
)
select s.sender as 'wallet', outgoing, incoming, (total_received - total_sent) as 'total'
from sent s left join received r
	on s.sender = r.recipient
order by wallet;













